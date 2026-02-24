# frozen_string_literal: true

module ::TechnogiqDiscourseModule
  class InviteManagerController < ::ApplicationController
    requires_plugin PLUGIN_NAME
    #require_dependency "invite_sender"
    #def index
      #render json: { hello: "world" }
    #end
    before_action :ensure_logged_in
    before_action :ensure_admin

    PER_PAGE = 10

    def index
      render json: { 
        invites: [],
        meta: {
          total: 0
        }
      }
    end

    def user
      render json: { 
        users: [],
        meta: {
          total: 0
        }
      }
    end

    def manageinvite
      page = params[:page].to_i
      page = 1 if page < 1
      per_page = params[:per_page]&.to_i || PER_PAGE

      offset = (page - 1) * per_page

      base_query = InviteMetadata
        .left_joins("LEFT JOIN user_invited ON user_invited.invite_id = invite_metadata.id")
        .group("invite_metadata.id")
        

      total_count = base_query.count.length

      invites = base_query
        .select(
          "invite_metadata.*,
           COUNT(user_invited.id) AS subscriber_count"
        )
        .order("invite_metadata.created_at DESC")
        .limit(per_page)
        .offset(offset)

      render json: {
        invites: invites.map { |i|
          {
            id: i.id,
            plan_type: i.plan_type,
            is_expiry_date: i.is_expiry_date,
            expiration_date: i.expiration_date,
            membership_duration_value: i.membership_duration_value,
            subscriber_count: i.subscriber_count.to_i,
            created_at: i.created_at
          }
        },
        meta: {
          page: page,
          per_page: per_page,
          total: total_count,
          total_pages: (total_count.to_f / per_page).ceil
        }
      }
    end

    def create
      is_expiry_date = params[:is_expiry_date]
      expiration_date = params[:expiration_date]
      plan_type = params[:plan_type]
      membership_duration_value = params[:membership_duration_value]
      metadata = params[:metadata] || {}
      renewal_period_value = params[:renewal_period_value]
      renewal_period = params[:renewal_period]
      description = params[:description]
      restrict_to = params[:restrict_to]
      max_uses = params[:max_uses]
      expire_after = params[:expire_after]
      arrive_at_topic = params[:arrive_at_topic]
      add_to_groups = params[:add_to_groups]
      number_of_invitations = params[:number_of_invitations]
      is_batch_mode = params[:is_batch_mode]

      base_metadata = params[:metadata] || {}
      enriched_metadata = base_metadata.merge({
        plan_type: plan_type,
        membership_duration_value: membership_duration_value,
        renewal_period: renewal_period,
        renewal_period_value: renewal_period_value,
        is_batch_mode: is_batch_mode,
        number_of_invitations: number_of_invitations,
        expiration_date: expiration_date,
        is_expiry_date: is_expiry_date,
      })

      expiry_date = (params[:expire_after].to_i).days.from_now
      number_of_invitations = is_batch_mode ? (number_of_invitations || 1).to_i : 1
      #invite = Invite.create(invited_by: current_user)
      #invite = Invite.create(invited_by: current_user, email: nil, max_redemptions_allowed: 5000)
      created_invites = []
      uniquestring = loop do
        token = SecureRandom.base58(12) # short + URL safe (Discourse style)
        break token unless InviteMetadata.exists?(uniqueid: token)
      end

      ActiveRecord::Base.transaction do
        number_of_invitations.times do
          #invite = Invite.create(invited_by: current_user, email: nil, max_redemptions_allowed: max_uses, description: description, domain:  restrict_to,  group_ids: add_to_groups, expires_at: expire_after, invite_to_topic: arrive_at_topic)
          invite = Invite.create(invited_by: current_user,
                     email: nil,
                     max_redemptions_allowed: max_uses,
                     description: description,
                     domain:  restrict_to,
                     #group_ids: 41, 
                     expires_at: expiry_date,
                     #topic_id: 1,
                   )

          raise StandardError, "Failed to create invite" unless invite

          if arrive_at_topic.present?
             invite.topic_invites.destroy_all
             invite.topic_invites.create!(topic_id: arrive_at_topic)
          end

          group_ids_array = add_to_groups.to_s.split(",").map(&:to_i)

          # 2. Add groups to the invite
          if group_ids_array.present?
            # Clear existing if necessary (standard Discourse pattern)
            #invite.invited_groups.destroy_all

            # Fetch group objects to ensure they exist before adding
            groups = Group.where(id: group_ids_array)

            groups.each do |group|
              invite.invited_groups.find_or_create_by!(group_id: group.id)
            end
          end

          invite_metadata = InviteMetadata.create!(
            invite_id: invite.id,
            is_expiry_date: is_expiry_date,
            expiration_date: is_expiry_date ? expiration_date : nil,
            plan_type: is_expiry_date ? nil : plan_type,
            membership_duration_value: is_expiry_date ? nil : membership_duration_value,
            metadata: enriched_metadata,
            uniqueid: uniquestring
          )
          created_invites << {
            invite_id: invite.id,
            invite_url: "#{Discourse.base_url}/invites/#{invite.invite_key}"
          } 
        end
      end

      render json: {
        status: "ok",
        #invite_id: invite.id,
        #invite_url: "#{Discourse.base_url}/invites/#{invite.invite_key}",
        #metadata: invite_metadata.metadata
        invites: created_invites,
        count: created_invites.size
      }
    rescue => e
      render json: { status: "error", message: e.message }, status: 500
    end
  end
end
