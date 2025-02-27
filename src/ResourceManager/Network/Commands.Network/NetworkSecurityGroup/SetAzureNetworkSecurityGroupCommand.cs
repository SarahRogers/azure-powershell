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
using MNM = Microsoft.Azure.Management.Network.Models;

namespace Microsoft.Azure.Commands.Network
{
    [Cmdlet(VerbsCommon.Set, "AzureRMNetworkSecurityGroup"), OutputType(typeof(PSNetworkSecurityGroup))]
    public class SetAzureNetworkSecurityGroupCommand : NetworkSecurityGroupBaseCmdlet
    {
        [Parameter(
            Mandatory = true,
            ValueFromPipeline = true,
            HelpMessage = "The NetworkSecurityGroup")]
        public PSNetworkSecurityGroup NetworkSecurityGroup { get; set; }

        protected override void ProcessRecord()
        {
            base.ProcessRecord();

            if (!this.IsNetworkSecurityGroupPresent(this.NetworkSecurityGroup.ResourceGroupName, this.NetworkSecurityGroup.Name))
            {
                throw new ArgumentException(Microsoft.Azure.Commands.Network.Properties.Resources.ResourceNotFound);
            }
            
            // Map to the sdk object
            var nsgModel = Mapper.Map<MNM.NetworkSecurityGroup>(this.NetworkSecurityGroup);
            nsgModel.Type = Microsoft.Azure.Commands.Network.Properties.Resources.NetworkSecurityGroupType;
            nsgModel.Tags = TagsConversionHelper.CreateTagDictionary(this.NetworkSecurityGroup.Tag, validate: true);

            // Execute the PUT NetworkSecurityGroup call
            this.NetworkSecurityGroupClient.CreateOrUpdate(this.NetworkSecurityGroup.ResourceGroupName, this.NetworkSecurityGroup.Name, nsgModel);

            var getNetworkSecurityGroup = this.GetNetworkSecurityGroup(this.NetworkSecurityGroup.ResourceGroupName, this.NetworkSecurityGroup.Name);
            WriteObject(getNetworkSecurityGroup);
        }
    }
}
