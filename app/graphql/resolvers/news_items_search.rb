# frozen_string_literal: true

require "search_object/plugin/graphql"

class Resolvers::NewsItemsSearch
  include SearchObject.module(:graphql)

  scope { NewsItem.all }

  type types[Types::NewsItemType]

  class NewsItemsOrder < ::Types::BaseEnum
    value "createdAt_ASC"
    value "createdAt_DESC"
    value "updatedAt_ASC"
    value "updatedAt_DESC"
    value "id_ASC"
    value "id_DESC"
  end

  option :limit, type: types.Int, with: :apply_limit
  option :skip, type: types.Int, with: :apply_skip
  option :order, type: NewsItemsOrder, default: "createdAt_DESC"

  def apply_limit(scope, value)
    scope.limit(value)
  end

  def apply_skip(scope, value)
    scope.offset(value)
  end

  def apply_order(scope, value)
    scope.order(value)
  end

  def apply_order_with_created_at_desc(scope)
    scope.order("created_at DESC")
  end

  def apply_order_with_created_at_asc(scope)
    scope.order("created_at ASC")
  end

  def apply_order_with_updated_at_desc(scope)
    scope.order("updated_at ASC")
  end

  def apply_order_with_updated_at_asc(scope)
    scope.order("updated_at ASC")
  end

  def apply_order_with_name_desc(scope)
    scope.order("name DESC")
  end

  def apply_order_with_name_asc(scope)
    scope.order("name ASC")
  end

  def apply_order_with_id_desc(scope)
    scope.order("id DESC")
  end

  def apply_order_with_id_asc(scope)
    scope.order("id ASC")
  end

  # TODO: Install and Implementb GrapQl Query Resolver to minimize N+1 SELECTS issued by ActiveRecord:
  # https://github.com/nettofarah/graphql-query-resolver
  # def fetch_results
  #   # NOTE: Don't run QueryResolver during tests
  #   return super unless context.present?

  #   GraphQL::QueryResolver.run(NewsItem, context, Types::NewsItemType) do
  #     super
  #   end
  # end
end
