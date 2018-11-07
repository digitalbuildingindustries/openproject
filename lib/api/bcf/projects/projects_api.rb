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
      class ProjectsAPI < ::Grape::API

        helpers do
          def project_representer(p)
            # cf = guid_cf
            # value = p.custom_value_for(cf).try(:value)
            #
            # unless value
            #   value = SecureRandom.uuid
            #   p.send("custom_field_#{cf.id}=", value)
            #   p.save!
            # end

            {
              project_id: p.id,
              name: p.name,
              authorization: {
              }
            }
          end
        end

        resources :projects do
          get do
            Project.visible.map(&method(:project_representer))
          end

          route_param :project_id do
            before do
              @project = Project.visible.find(params[:project_id])
            end

            get do
              project_representer(@project)
            end

            mount ::API::BCF::Projects::TopicsAPI
          end
        end
      end
    end
  end
end
