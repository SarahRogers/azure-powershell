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
using System.Management.Automation;
using AutoMapper;
using Microsoft.Azure.Commands.Tags.Model;
using Microsoft.Azure.Management.Network;
using Microsoft.Azure.Commands.Network.Models;
using Microsoft.Azure.Commands.Resources.Models;
using MNM = Microsoft.Azure.Management.Network.Models;

namespace Microsoft.Azure.Commands.Network
{
    [Cmdlet(VerbsCommon.Set, "AzureRMApplicationGateway"), OutputType(typeof(PSApplicationGateway))]
    public class SetAzureApplicationGatewayCommand : ApplicationGatewayBaseCmdlet
    {
        [Parameter(
             Mandatory = true,
             ValueFromPipeline = true,
             HelpMessage = "The applicationGateway")]
        public PSApplicationGateway ApplicationGateway { get; set; }

        protected override void ProcessRecord()
        {
            base.ProcessRecord();

            if (!this.IsApplicationGatewayPresent(this.ApplicationGateway.ResourceGroupName, this.ApplicationGateway.Name))
            {
                throw new ArgumentException(Microsoft.Azure.Commands.Network.Properties.Resources.ResourceNotFound);
            }

            // Normalize the IDs
            ApplicationGatewayChildResourceHelper.NormalizeChildResourcesId(this.ApplicationGateway);

            // Map to the sdk object
            var appGwModel = Mapper.Map<MNM.ApplicationGateway>(this.ApplicationGateway);
            appGwModel.Type = Microsoft.Azure.Commands.Network.Properties.Resources.ApplicationGatewayType;
            appGwModel.Tags = TagsConversionHelper.CreateTagDictionary(this.ApplicationGateway.Tag, validate: true);

            // Execute the Create VirtualNetwork call
            this.ApplicationGatewayClient.CreateOrUpdate(this.ApplicationGateway.ResourceGroupName, this.ApplicationGateway.Name, appGwModel);

            var getApplicationGateway = this.GetApplicationGateway(this.ApplicationGateway.ResourceGroupName, this.ApplicationGateway.Name);
            WriteObject(getApplicationGateway);
        }
    }
}
