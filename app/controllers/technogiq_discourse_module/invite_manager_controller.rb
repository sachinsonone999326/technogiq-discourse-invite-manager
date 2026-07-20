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

    skip_before_action :ensure_admin,
      only: [:membership_expiry]

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

    def datamanageinvites

      page = params[:page].to_i
      page = 1 if page < 1
      per_page = params[:per_page]&.to_i || PER_PAGE

      offset = (page - 1) * per_page

      invites_data = InviteBatch
      .joins("
        LEFT JOIN invite_metadata
          ON invite_metadata.batch_id = invite_batches.id
        LEFT JOIN invites
          ON invites.id = invite_metadata.invite_id

        LEFT JOIN user_invited
          ON user_invited.batch_id = invite_batches.id
      ")
      .select("
        invite_batches.*,
        COUNT(DISTINCT user_invited.invite_id) AS total_user_invites,
        MAX(
          CASE
            WHEN invites.expires_at IS NOT NULL
             AND invites.expires_at < NOW()
            THEN 1
            ELSE 0
          END
        ) AS is_expired,

        STRING_AGG(DISTINCT invites.description, ', ') AS description,

        STRING_AGG(CONCAT('#{Discourse.base_url}/invites/', invites.invite_key), ', ') AS invite_url,

        STRING_AGG(
          DISTINCT (
            SELECT STRING_AGG(g.name, ', ')
            FROM invited_groups ig
            JOIN groups g ON g.id = ig.group_id
            WHERE ig.invite_id = invites.id
          ),
          ', '
        ) AS group_names
      ")
      .group("invite_batches.id")
      .order("invite_batches.batch_number DESC")

      invites = invites_data.map do |batch|

        total = batch.total_invites.to_i
        redeemed = batch.total_user_invites.to_i
        expired = batch.is_expired.to_i

        remaining = total - redeemed
        remaining = 0 if remaining < 0

        batch.attributes.merge(
          "is_completed" => expired > 0 || remaining == 0,
          "is_active" => expired == 0 && remaining > 0,
          "remaining_invites" => remaining,
        )
      end

      render json: {
        invites: invites,
        meta: {
          total: 0
        }
      }
    end

    def dataallinvitesurl

      batch_id = params[:batch_id]
     

      invites_data = InviteMetadata
          .select("invite_metadata.id, invites.invite_key ") 
          .joins("JOIN invites ON invites.id = invite_metadata.invite_id")
          .where(batch_id: batch_id)
          .order("invite_metadata.id DESC, invite_metadata.created_at DESC")

      


      render json: {
        invites: invites_data.to_a,
        baseUrl: "#{Discourse.base_url}",
        total: 0#invites_data.count
      }
    end


    def datainvitedetails

      batch_id = params[:batch_id]

      invite = Invite
       .joins("JOIN invite_metadata ON invite_metadata.invite_id = invites.id")
       .select("invites.*, invite_metadata.metadata AS metadata, invite_metadata.membership_duration_value, 
               invite_metadata.renewal_period, invite_metadata.renewal_period_value, invite_metadata.is_batch_mode, 
               invite_metadata.number_of_invitations, invite_metadata.plan_type,
               invite_metadata.is_expiry_date, invite_metadata.expiration_date")
       .where("invite_metadata.batch_id = ?", params[:batch_id])
       .includes(:groups, :topics)
       .first

      total_user_invites = UserInviteum.where(batch_id: params[:batch_id]).count

      render json: {invite: 
      {
        id: invite.id,
        invite_key: invite.invite_key,
        description: invite.description,
        metadata: invite.metadata,
        status: case
          when invite.expires_at.present? &&
              invite.expires_at < Time.now
              "Disabled"

          when total_user_invites == invite.number_of_invitations
              "Disabled"

          else
              "Enabled"
        end,
        total_user_invites: total_user_invites,
        total_user_remaining_invites: (invite.number_of_invitations - total_user_invites),
        invite: invite,
        groups: invite.groups.map { |g| { id: g.id, name: g.name } },
        topics: invite.topics.map { |t| { id: t.id, title: t.title } }
       }
      }
     
    end

    
    def manageinvite

      page = params[:page].to_i
      page = 1 if page < 1
      per_page = params[:per_page]&.to_i || PER_PAGE

      offset = (page - 1) * per_page

      render json: {
        #invites: invites_data.map { |i| { id: 5 }},
        meta: {
          total: 0
        }
      }
    end
    
    def manageinvite1
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

    def datamanageusers

      page = params[:page].to_i
      page = 1 if page < 1
      per_page = params[:per_page]&.to_i || PER_PAGE

      offset = (page - 1) * per_page


      invites_data = UserInviteum
                 .joins("JOIN users u ON u.id = user_invited.user_id")
                 .joins("LEFT JOIN user_emails ue ON ue.user_id = u.id AND ue.primary = true")
                 .joins("LEFT JOIN invites i ON i.id = user_invited.invite_id")
                 .select("user_invited.*,
                          u.username,
                          u.created_at AS registration_date,
                          ue.email,
                          i.description,
                          i.invite_key,
                          CONCAT('#{Discourse.base_url}/invites/', i.invite_key) AS invite_url,
                          i.created_at AS invite_created_at")
                 .order("user_invited.created_at DESC")
 

      render json: {
        invites: invites_data.to_a,
        baseUrl: "#{Discourse.base_url}",
        meta: {
          total: 0
        }
      }
    end

    def membership_expiry
       user = current_user

       return render_json_error("User not found") unless user

       invite_record = UserInviteum.find_by(user_id: user.id)

       render json: {
         expiry_date: invite_record&.expiration_date&.strftime("%d %b %Y")
       }
    end

    def datamanageusersbyid

      invite_id = params[:user_id]

      
      invites = UserInviteum
                 .joins("JOIN users u ON u.id = user_invited.user_id")
                 .joins("LEFT JOIN user_emails ue ON ue.user_id = u.id AND ue.primary = true")
                 .joins("LEFT JOIN invites i ON i.id = user_invited.invite_id")
                 .select("user_invited.*,
                          u.username,
                          u.created_at AS registration_date,
                          ue.email,
                          i.description,
                          i.invite_key,
                          i.created_at AS invite_created_at")
                 .where("user_invited.id = ?", params[:user_id])
                 .order("user_invited.created_at DESC")


      render json: {invites: invites.map { |invite|
      {
        id: invite.id,
        user_id: invite.user_id,
        is_expiry_date: invite.is_expiry_date,
        expiration_date: invite.expiration_date,
        invite: invite,
        username: invite.username
       }
      }
     }
    end
    
    
    def getuserbyid

      invite_id = params[:id]

      
      invites = UserInviteum
                 .joins("JOIN users u ON u.id = user_invited.user_id")
                 .joins("LEFT JOIN user_emails ue ON ue.user_id = u.id AND ue.primary = true")
                 .joins("LEFT JOIN invites i ON i.id = user_invited.invite_id")
                 .select("user_invited.*,
                          u.username,
                          u.created_at AS registration_date,
                          ue.email,
                          i.description,
                          i.invite_key,
                          i.created_at AS invite_created_at")
                 .where("user_invited.id = ?", params[:id])
                 .order("user_invited.created_at DESC")


      render json: {invites: invites.map { |invite|
      {
        id: invite.id,
        user_id: invite.user_id,
        is_expiry_date: invite.is_expiry_date,
        expiration_date: invite.expiration_date,
        invite: invite,
        username: invite.username
       }
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

      description = description.to_s.strip

      if description.length > 100
        raise Discourse::InvalidParameters.new(
              "Description cannot be longer than 100 characters."
        )
      end

      # Renewal period validation
      renewal_period = renewal_period.to_s
      renewal_period_value = renewal_period_value.to_i

      if renewal_period != "monthly"
        if renewal_period_value != 1
          raise Discourse::InvalidParameters.new(
            "Allowed renewal period must be 1 unless the Renewal Period is Monthly."
          )
          
        end

        # Sanitize the value
        renewal_period_value = 1
      else
        if renewal_period_value < 1
          raise Discourse::InvalidParameters.new(
            "Allowed renewal period must be at least 1 for Monthly renewal."
          )
          return
        end
      end

      max_limit = SiteSetting.invite_link_max_redemptions_limit.to_i

      if max_uses > max_limit
        raise StandardError, "Maximum redemptions cannot exceed #{max_limit}."
      end

      base_metadata = params[:metadata] || {}
      

      expiry_date = (params[:expire_after].to_i).days.from_now
      number_of_invitations = is_batch_mode ? (number_of_invitations || 1).to_i : 1

      input1 = restrict_to

      if input1.match?(URI::MailTo::EMAIL_REGEXP)
        email1 = input1
        domain1 = nil
      else
        email1 = nil
        domain1 = input1
      end
      #invite = Invite.create(invited_by: current_user)
      #invite = Invite.create(invited_by: current_user, email: nil, max_redemptions_allowed: 5000)
      created_invites = []
      uniquestring = loop do
        token = SecureRandom.base58(12) # short + URL safe (Discourse style)
        break token unless InviteMetadata.exists?(uniqueid: token)
      end


      batch_number = (InviteBatch.maximum(:batch_number) || 0) + 1

      batch = InviteBatch.create!(
            batch_number: batch_number,
            created_by_id: current_user.id,
            description: description,
            expires_at: expiry_date,
            total_invites: number_of_invitations,
            redeemed_count: 0,
            expired_count: 0
      )

      ActiveRecord::Base.transaction do
        number_of_invitations.times do
          #invite = Invite.create(invited_by: current_user, email: nil, max_redemptions_allowed: max_uses, description: description, domain:  restrict_to,  group_ids: add_to_groups, expires_at: expire_after, invite_to_topic: arrive_at_topic)
          invite = Invite.create(invited_by: current_user,
                     email: email1,
                     max_redemptions_allowed: max_uses,
                     description: description,
                     domain:  domain1,
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
            batch_id: batch.id,
            is_expiry_date: is_expiry_date,
            expiration_date: is_expiry_date ? expiration_date : nil,
            plan_type: is_expiry_date ? nil : plan_type,
            membership_duration_value: is_expiry_date ? nil : membership_duration_value,
            metadata: base_metadata,
            renewal_period: renewal_period,
            renewal_period_value: renewal_period_value,
            is_batch_mode: is_batch_mode,
            number_of_invitations: number_of_invitations,
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
  

    def extendmembershipupdate
      expiration_date = params[:expiration_date]
      plan_type = params[:plan_type]
      membership_duration_value = params[:membership_duration_value]
      renewal_period_value = params[:renewal_period_value]
      renewal_period = params[:renewal_period]
      selectedMode = params[:selectedMode]
      id = params[:id]
      invite = UserInviteum.find_by(id: params[:id])

      return render json: {
        status: "error",
        message: "Invite not found."
      } unless invite

      if selectedMode == "date"

        if expiration_date.nil? || expiration_date.empty?
          return render json: {
            status: "error",
            message: "Invalid expiration date."
          }
        end

        expiry = Date.parse(expiration_date)

        if expiry <= Date.current
          return render json: {
            status: "error",
            message: "Expiration date must be greater than today's date."
          }
        end
      
      end

      if renewal_period != "monthly"
        if renewal_period_value != 1
          
          return render json: {
            status: "error",
            message: "Allowed renewal period must be 1 unless the Renewal Period is Monthly."
          }
        end

        # Sanitize the value
        renewal_period_value = 1
      else
        if renewal_period_value < 1
          
          return render json: {
            status: "error",
            message: "Allowed renewal period must be at least 1 for Monthly renewal."
          }
          
        end
      end

      
      if invite.present?
        if selectedMode == "date"
          
          invite.update(
            expiration_date: expiration_date,
            calculate_date: expiration_date,
            renewal_period_value: renewal_period_value,
            renewal_period: renewal_period
           )
           render json: {
             status: "ok",
           }
        end
         
        if selectedMode == "duration"
          invite.update(
            expiration_date: expiration_date,
            calculate_date: expiration_date,
            plan_type: plan_type,
            membership_duration_value: membership_duration_value,
            renewal_period_value: renewal_period_value,
            renewal_period: renewal_period
            
           )
           
          render json: {
            status: "ok",
          }
        end

      end
      
      if !selectedMode
        render json: { status: "error", message: "Records not updated" }
      end
      
    end


    def editmetadata
      
      id = params[:id]
      metadata = params[:metadata] || {}
      invite = UserInviteum.find_by(id: params[:id])

      unless invite.present?
        return render json: {
          status: "error",
          message: "Invite not found"
        }
      end

      if invite.present?
        
        metadataold = invite.metadata || {}
        
        invite.update(
            metadata: metadata,

       )

        
        render json: {
            status: "ok",
          }
        
      end


    end

    def download_json

     invite = Invite
       .joins("JOIN invite_metadata ON invite_metadata.invite_id = invites.id")
       .select("invites.*, invite_metadata.metadata AS metadata, invite_metadata.id AS invite_meta_id,
               invite_metadata.is_expiry_date,invite_metadata.plan_type, invite_metadata.membership_duration_value, 
               invite_metadata.expiration_date, invite_metadata.uniqueid,invite_metadata.batch_id,
               invite_metadata.is_batch_mode, invite_metadata.renewal_period, invite_metadata.renewal_period_value, invite_metadata.number_of_invitations")
       .where("invite_metadata.batch_id = ?", params[:id])
       .includes(:groups, :topics)
       .first

     total_user_invites = UserInviteum.where(batch_id: params[:id]).count

     invites_data = InviteMetadata
          .select("invite_metadata.id, invites.invite_key ")
          .joins("JOIN invites ON invites.id = invite_metadata.invite_id")
          .where(batch_id: params[:id])
          .order("invite_metadata.id DESC, invite_metadata.created_at DESC")




     excluded_keys = [
      
     ]

     custom_metadata =
       (invite.metadata || {})
       .except(*excluded_keys)

     data = {
       id: invite.invite_meta_id,
       created_at: invite.created_at,
       description: invite.description,
       max_redemptions_allowed: invite.max_redemptions_allowed,
       redemption_count: invite.redemption_count,
       expires_after: invite.expires_at,
       email: invite.email,
       domain: invite.domain,
       is_expiry_date: invite.is_expiry_date,
       plan_type: invite.plan_type,
       membership_duration_value: invite.membership_duration_value, 
       renewal_period: invite.renewal_period,
       renewal_period_value: invite.renewal_period_value,
       number_of_invitations: invite.number_of_invitations,
       is_batch_mode: invite.is_batch_mode,
       membership_expiration_date: invite.expiration_date,
       metadata: custom_metadata,
       total_user_invites: total_user_invites,
       status: case
         when invite.expires_at.present? &&
              invite.expires_at < Time.now
              "completed"

         when total_user_invites == invite.number_of_invitations
              "completed"

         else
              "active"
         end,
       invites_url: invites_data.map{ |u| { url: "#{Discourse.base_url}/invites/#{u.invite_key}" } },
       groups: invite.groups.map { |g| { id: g.id, name: g.name } },
       topics: invite.topics.map { |t| { id: t.id, title: t.title } }

     }

      send_data(
         JSON.pretty_generate(data.as_json),
         filename: "invite-#{invite.batch_id}.json",
         type: "application/json"
      )
    end
  end
end
