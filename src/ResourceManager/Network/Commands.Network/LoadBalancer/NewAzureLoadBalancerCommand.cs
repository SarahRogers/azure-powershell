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

using System.Collections;
using System.Collections.Generic;
using System.Management.Automation;
using AutoMapper;
using Microsoft.Azure.Commands.Tags.Model;
using Microsoft.Azure.Management.Network;
using Microsoft.Azure.Commands.Network.Models;
using Microsoft.Azure.Commands.Resources.Models;
using MNM = Microsoft.Azure.Management.Network.Models;

namespace Microsoft.Azure.Commands.Network
{
    [Cmdlet(VerbsCommon.New, "AzureRMLoadBalancer"), OutputType(typeof(PSLoadBalancer))]
    public class NewAzureLoadBalancerCommand : LoadBalancerBaseCmdlet
    {
        [Alias("ResourceName")]
        [Parameter(
            Mandatory = true,
            ValueFromPipelineByPropertyName = true,
            HelpMessage = "The resource name.")]
        [ValidateNotNullOrEmpty]
        public virtual string Name { get; set; }

        [Parameter(
            Mandatory = true,
            ValueFromPipelineByPropertyName = true,
            HelpMessage = "The resource group name.")]
        [ValidateNotNullOrEmpty]
        public virtual string ResourceGroupName { get; set; }

        [Parameter(
         Mandatory = true,
         ValueFromPipelineByPropertyName = true,
         HelpMessage = "location.")]
        [ValidateNotNullOrEmpty]
        public virtual string Location { get; set; }

        [Parameter(
             Mandatory = false,
             ValueFromPipelineByPropertyName = true,
             HelpMessage = "The list of frontend Ip config")]
        [ValidateNotNullOrEmpty]
        public List<PSFrontendIPConfiguration> FrontendIpConfiguration { get; set; }

        [Parameter(
             Mandatory = false,
             ValueFromPipelineByPropertyName = true,
             HelpMessage = "The list of frontend Ip config")]
        public List<PSBackendAddressPool> BackendAddressPool { get; set; }

        [Parameter(
             Mandatory = false,
             ValueFromPipelineByPropertyName = true,
             HelpMessage = "The list of frontend Ip config")]
        public List<PSProbe> Probe { get; set; }

        [Parameter(
             Mandatory = false,
             ValueFromPipelineByPropertyName = true,
             HelpMessage = "The list of frontend Ip config")]
        public List<PSInboundNatRule> InboundNatRule { get; set; }

        [Parameter(
             Mandatory = false,
             ValueFromPipelineByPropertyName = true,
             HelpMessage = "The list of frontend Ip config")]
        public List<PSLoadBalancingRule> LoadBalancingRule { get; set; }

        [Parameter(
            Mandatory = false,
            ValueFromPipelineByPropertyName = true,
            HelpMessage = "An array of hashtables which represents resource tags.")]
        public Hashtable[] Tag { get; set; }

        [Parameter(
            Mandatory = false,
            HelpMessage = "Do not ask for confirmation if you want to overrite a resource")]
        public SwitchParameter Force { get; set; }

        protected override void ProcessRecord()
        {
            base.ProcessRecord();

            if (this.IsLoadBalancerPresent(this.ResourceGroupName, this.Name))
            {
                ConfirmAction(
                    Force.IsPresent,
                    string.Format(Microsoft.Azure.Commands.Network.Properties.Resources.OverwritingResource, Name),
                    Microsoft.Azure.Commands.Network.Properties.Resources.OverwritingResourceMessage,
                    Name,
                    () => CreateLoadBalancer());

                WriteObject(this.GetLoadBalancer(this.ResourceGroupName, this.Name));
            }
            else
            {
                var loadBalancer = this.CreateLoadBalancer();

                WriteObject(loadBalancer);
            }
        }

        private PSLoadBalancer CreateLoadBalancer()
        {
            var loadBalancer = new PSLoadBalancer();
            loadBalancer.Name = this.Name;
            loadBalancer.ResourceGroupName = this.ResourceGroupName;
            loadBalancer.Location = this.Location;

            if (this.FrontendIpConfiguration != null)
            {
                loadBalancer.FrontendIpConfigurations = new List<PSFrontendIPConfiguration>();
                loadBalancer.FrontendIpConfigurations = this.FrontendIpConfiguration;
            }

            if (this.BackendAddressPool != null)
            {
                loadBalancer.BackendAddressPools = new List<PSBackendAddressPool>();
                loadBalancer.BackendAddressPools = this.BackendAddressPool;
            }

            if (this.Probe != null)
            {
                loadBalancer.Probes = new List<PSProbe>();
                loadBalancer.Probes = this.Probe;
            }

            if (this.InboundNatRule != null)
            {
                loadBalancer.InboundNatRules = new List<PSInboundNatRule>();
                loadBalancer.InboundNatRules = this.InboundNatRule;
            }

            if (this.LoadBalancingRule != null)
            {
                loadBalancer.LoadBalancingRules = new List<PSLoadBalancingRule>();
                loadBalancer.LoadBalancingRules = this.LoadBalancingRule;
            }

            // Normalize the IDs
            ChildResourceHelper.NormalizeChildResourcesId(loadBalancer);

            // Map to the sdk object
            var lbModel = Mapper.Map<MNM.LoadBalancer>(loadBalancer);
            lbModel.Type = Microsoft.Azure.Commands.Network.Properties.Resources.LoadBalancerType;
            lbModel.Tags = TagsConversionHelper.CreateTagDictionary(this.Tag, validate: true);

            // Execute the Create VirtualNetwork call
            this.LoadBalancerClient.CreateOrUpdate(this.ResourceGroupName, this.Name, lbModel);

            var getLoadBalancer = this.GetLoadBalancer(this.ResourceGroupName, this.Name);

            return getLoadBalancer;
        }
    }
}
