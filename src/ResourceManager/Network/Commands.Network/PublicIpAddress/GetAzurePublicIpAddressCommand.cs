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

using System.Collections.Generic;
using System.Management.Automation;
using Microsoft.Azure.Management.Network;
using Microsoft.Azure.Commands.Network.Models;
using MNM = Microsoft.Azure.Management.Network.Models;

namespace Microsoft.Azure.Commands.Network
{
    [Cmdlet(VerbsCommon.Get, "AzureRMPublicIpAddress"), OutputType(typeof(PSPublicIpAddress))]
    public class GetAzurePublicIpAddressCommand : PublicIpAddressBaseCmdlet
    {
        [Alias("ResourceName")]
        [Parameter(
            Mandatory = false,
            ValueFromPipelineByPropertyName = true,
            HelpMessage = "The resource name.")]
        [ValidateNotNullOrEmpty]
        public virtual string Name { get; set; }

        [Parameter(
            Mandatory = false,
            ValueFromPipelineByPropertyName = true,
            HelpMessage = "The resource group name.")]
        [ValidateNotNullOrEmpty]
        public virtual string ResourceGroupName { get; set; }

        protected override void ProcessRecord()
        {
            base.ProcessRecord();
            if (!string.IsNullOrEmpty(this.Name))
            {
                var publicIp = this.GetPublicIpAddress(this.ResourceGroupName, this.Name);
                
                WriteObject(publicIp);
            }
            else if (!string.IsNullOrEmpty(this.ResourceGroupName))
            {
                var getPublicIpResponse = this.PublicIpAddressClient.List(this.ResourceGroupName);

                var psPublicIps = new List<PSPublicIpAddress>();
                
                // populate the publicIpAddresses with the ResourceGroupName
                foreach (var publicIp in getPublicIpResponse.PublicIpAddresses)
                {
                    var psPublicIp = this.ToPsPublicIpAddress(publicIp);
                    psPublicIp.ResourceGroupName = this.ResourceGroupName;
                    psPublicIps.Add(psPublicIp);
                }

                WriteObject(psPublicIps, true);
            }
            else
            {
                var getPublicIpResponse = this.PublicIpAddressClient.ListAll();

                var psPublicIps = new List<PSPublicIpAddress>();

                // populate the publicIpAddresses with the ResourceGroupName
                foreach (var publicIp in getPublicIpResponse.PublicIpAddresses)
                {
                    var psPublicIp = this.ToPsPublicIpAddress(publicIp);
                    psPublicIp.ResourceGroupName = NetworkBaseCmdlet.GetResourceGroup(publicIp.Id);
                    psPublicIps.Add(psPublicIp);
                }

                WriteObject(psPublicIps, true);
            }
        }
    }
}

 