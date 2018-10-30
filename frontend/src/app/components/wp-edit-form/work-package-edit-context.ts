// -- copyright
// OpenProject is a project management system.
// Copyright (C) 2012-2017 the OpenProject Foundation (OPF)
//
// This program is free software; you can redistribute it and/or
// modify it under the terms of the GNU General Public License version 3.
//
// OpenProject is a fork of ChiliProject, which is a fork of Redmine. The copyright follows:
// Copyright (C) 2006-2017 Jean-Philippe Lang
// Copyright (C) 2010-2013 the ChiliProject Team
//
// This program is free software; you can redistribute it and/or
// modify it under the terms of the GNU General Public License
// as published by the Free Software Foundation; either version 2
// of the License, or (at your option) any later version.
//
// This program is distributed in the hope that it will be useful,
// but WITHOUT ANY WARRANTY; without even the implied warranty of
// MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
// GNU General Public License for more details.
//
// You should have received a copy of the GNU General Public License
// along with this program; if not, write to the Free Software
// Foundation, Inc., 51 Franklin Street, Fifth Floor, Boston, MA  02110-1301, USA.
//
// See doc/COPYRIGHT.rdoc for more details.
// ++

import {WorkPackageResource} from 'core-app/modules/hal/resources/work-package-resource';
import {WorkPackageEditForm} from './work-package-edit-form';
import {WorkPackageEditFieldHandler} from './work-package-edit-field-handler';
import {IFieldSchema} from "core-app/modules/fields/field.base";

export interface WorkPackageEditContext {
  /**
   * Activate the field, returning the element and associated field handler
   */
  activateField(form:WorkPackageEditForm, schema:IFieldSchema, fieldName:string, errors:string[]):Promise<WorkPackageEditFieldHandler>;

  /**
   * Show this required field. E.g., add the necessary column
   */
  requireVisible(fieldName:string):Promise<void>;

  /**
   * Reset the field and re-render the current WPs value.
   */
  reset(workPackage:WorkPackageResource, fieldName:string, focus?:boolean):void;

  /**
   * Return the first relevant field from the given list of attributes.
   */
  firstField(names:string[]):string;

  /**
   * Optional callback when the form is being saved
   */
  onSaved(isInitial:boolean, savedWorkPackage:WorkPackageResource):void;
}
