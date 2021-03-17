# frozen_string_literal: true

class ResourceService
  attr_accessor :data_provider
  attr_accessor :resource
  attr_accessor :resource_class

  def initialize(data_provider:)
    @data_provider = data_provider
  end

  def create(resource_class, params)
    @params = params

    # Erlaube nur ein Anlegen von Daten wenn der Nutzer nicht ReadOnly ist.
    raise "Access not permitted" if data_provider.user.read_only_role?

    # Wenn die Rolle Restricted eine Information anlegt,
    # so ist diese per default nicht sichtbar, es sei denn
    # das Attribute 'visible' wird in den params mitgegeben und ist 'true'
    if @data_provider.user.restricted_role? && resource_class.respond_to?(:visible)
      @params = { visible: false }.merge(@params)
    end

    @resource_class = resource_class
    @resource = resource_class.new(@params)
    @resource.data_provider = @data_provider

    # skip create if record already exists and new record has the same attribute values as the new
    # record and the record is not marked as 'always_recreate'
    @external_resource = find_external_resource
    @old_resource = find_old_resource
    if @external_resource.present? && unchanged_attributes? && !always_recreate?
      @external_resource.touch
      return @old_resource
    end

    create_or_recreate
    resource_or_error_message(@resource)
  end

  def find_old_resource
    @external_resource.try(:external)
  end

  def create_or_recreate
    if @old_resource.present?
      update_resource
    else
      create_new_resource
    end
  end

  def update_resource
    # @old_resource.update(@params)
    @old_resource.destroy if @old_resource.present?
    create_new_resource

    set_default_categories if @resource.respond_to?(:categories)
  end

  def create_new_resource
    ActiveRecord::Base.transaction do
      @external_resource.destroy if @external_resource.present?
      if @resource.save
        create_external_resource
        FacebookService.delay.send_post_to_page(resource_id: @resource.id, resource_type: @resource_class.name)
        set_default_categories if @resource.respond_to?(:categories)
      else
        GraphQL::ExecutionError.new("Invalid input: #{@resource.errors.full_messages.join(', ')}")
      end
    end
  end

  def unchanged_attributes?
    return false if @old_resource.blank?
    if @old_resource.respond_to?(:compareable_attributes)
      return @resource.compareable_attributes == @old_resource.compareable_attributes
    end

    # Fallback, wenn :compareable_attributes nicht beim Model definiert ist.
    except_attributes = ["id", "created_at", "updated_at", "tag_list", "category_id", "region_id", "visible"]
    @resource.attributes.except(*except_attributes) == @old_resource.attributes.except(*except_attributes)
  end

  def always_recreate?
    return false if @data_provider.blank?

    class_name = @resource_class.name
    setting = @data_provider.data_resource_settings.where(data_resource_type: class_name).first
    return false if setting.blank?

    setting.always_recreate_on_import == "true"
  end

  def find_external_resource
    return nil if @params.fetch(:force_create, false)

    ExternalReference.find_by(
      data_provider: @data_provider,
      external_type: @resource_class,
      unique_id: resource.unique_id
    )
  end

  def create_external_resource
    ExternalReference.create(
      data_provider: @data_provider,
      external_id: resource.id,
      external_type: @resource_class,
      unique_id: resource.unique_id
    )
  end

  def resource_or_error_message(record)
    if record.valid?
      record
    else
      GraphQL::ExecutionError.new("Invalid input: #{record.errors.full_messages.join(", ")}")
    end
  end

  def set_default_categories
    setting = @data_provider.data_resource_settings.where(data_resource_type: @resource_class.name).first
    return if setting.blank?
    return if setting.default_category_ids.blank?

    categories_to_add = setting.default_category_ids.compact.uniq.delete_if(&:blank?)
    return if categories_to_add.blank?

    categories_to_add.each do |cat_id|
      category = Category.find_by(id: cat_id)
      @resource.categories << category unless @resource.category_ids.include?(cat_id.to_i)
    end
  end
end
