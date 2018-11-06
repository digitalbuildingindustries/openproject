#-- copyright
# OpenProject is a project management system.
# Copyright (C) 2012-2018 the OpenProject Foundation (OPF)
#
# This program is free software; you can redistribute it and/or
# modify it under the terms of the GNU General Public License version 3.
#
# OpenProject is a fork of ChiliProject, which is a fork of Redmine. The copyright follows:
# Copyright (C) 2006-2017 Jean-Philippe Lang
# Copyright (C) 2010-2013 the ChiliProject Team
#
# This program is free software; you can redistribute it and/or
# modify it under the terms of the GNU General Public License
# as published by the Free Software Foundation; either version 2
# of the License, or (at your option) any later version.
#
# This program is distributed in the hope that it will be useful,
# but WITHOUT ANY WARRANTY; without even the implied warranty of
# MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
# GNU General Public License for more details.
#
# You should have received a copy of the GNU General Public License
# along with this program; if not, write to the Free Software
# Foundation, Inc., 51 Franklin Street, Fifth Floor, Boston, MA  02110-1301, USA.
#
# See docs/COPYRIGHT.rdoc for more details.
#++
require 'securerandom'

module API
  module BCF
    module Projects
      class TopicsAPI < ::Grape::API

        helpers do
          def guid_cf
            @cf ||= WorkPackageCustomField.find_by(name: 'GUID')
          end

          def topic_type
            Type.find_by(name: 'Mängel') || Type.first
          end

          def topic_representer(wp, value = nil)
            value ||= wp.custom_value_for(guid_cf).try(:value)
            unless value
              value = SecureRandom.uuid
              wp.send("custom_field_#{guid_cf.id}=", value)
              wp.save!
            end
            {
              guid: value,
              creation_author: wp.author.mail,
              creation_date: wp.created_at.iso8601,
              modified_date: wp.updated_at.iso8601,
              title: wp.subject
            }
          end
        end

        resources :topics do
          before do
            authorize(:view_work_packages, context: @project)
          end

          get do
            WorkPackage
              .where(type_id: topic_type.id)
              .all
              .map(&method(:topic_representer))
          end

          route_param :guid do
            get do
              binding.pry
              cv = CustomValue.where(custom_field_id: guid_cf.id, value: params[:guid]).select(:customized_id)
              wp = WorkPackage.where(id: cv).first

              topic_representer(wp, params[:guid])
            end
          end
        end
      end
    end
  end
end
