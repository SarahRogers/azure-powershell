﻿// ----------------------------------------------------------------------------------
//
// Copyright Microsoft Corporation
// Licensed under the Apache License, Version 2.0 (the "License");
// you may not use this file except in compliance with the License.
// You may obtain a copy of the License at
// http://www.apache.org/licenses/LICENSE-2.0
// Unless required by applicable law or agreed to in writing, software
// distributed under the License is distributed on an "AS IS" BASIS,
// WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
// See the License for the specific language governing permissions and
// limitations under the License.
// ----------------------------------------------------------------------------------

using System;
using System.Collections.Generic;
using System.Management.Automation;
using System.Security.Permissions;
using Microsoft.Azure.Commands.Automation.Model;
using Microsoft.Azure.Commands.Automation.Common;
using Microsoft.Azure.Commands.Automation.Properties;

namespace Microsoft.Azure.Commands.Automation.Cmdlet
{
    /// <summary>
    /// Remove a Module for automation.
    /// </summary>
    [Cmdlet(VerbsCommon.Remove, "AzureRMAutomationModule", DefaultParameterSetName = AutomationCmdletParameterSets.ByName)]
    public class RemoveAzureAutomationModule : AzureAutomationBaseCmdlet
    {
        /// <summary>
        /// Gets or sets the module name.
        /// </summary>
        [Parameter(ParameterSetName = AutomationCmdletParameterSets.ByName, Position = 2, Mandatory = true, ValueFromPipelineByPropertyName = true, HelpMessage = "The module name.")]
        [ValidateNotNullOrEmpty]
        public string Name { get; set; }

        [Parameter(ParameterSetName = AutomationCmdletParameterSets.ByName, Position = 3, HelpMessage = "Confirm the removal of the module")]
        public SwitchParameter Force { get; set; }

        /// <summary>
        /// Execute this cmdlet.
        /// </summary>
        [PermissionSet(SecurityAction.Demand, Name = "FullTrust")]
        protected override void AutomationProcessRecord()
        {
            ConfirmAction(
                       Force.IsPresent,
                       string.Format(Resources.RemovingAzureAutomationResourceWarning, "Module"),
                       string.Format(Resources.RemoveAzureAutomationResourceDescription, "Module"),
                       Name,
                       () =>
                       {
                           this.AutomationClient.DeleteModule(this.ResourceGroupName, this.AutomationAccountName, Name);
                       });
        }
    }
}
