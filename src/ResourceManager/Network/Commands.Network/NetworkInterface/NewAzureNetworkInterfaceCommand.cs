﻿

// ----------------------------------------------------------------------------------
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
    [Cmdlet(VerbsCommon.New, "AzureRMNetworkInterface"), OutputType(typeof(PSNetworkInterface))]
    public class NewAzureNetworkInterfaceCommand : NetworkInterfaceBaseCmdlet
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
            HelpMessage = "The public IP address location.")]
        [ValidateNotNullOrEmpty]
        public string Location { get; set; }

        [Parameter(
            Mandatory = false,
            ValueFromPipelineByPropertyName = true,
            HelpMessage = "The private ip address of the Network Interface " +
                          "if static allocation is specified.")]
        public string PrivateIpAddress { get; set; }

        [Parameter(
            Mandatory = true,
            ValueFromPipelineByPropertyName = true,
            ParameterSetName = "SetByResourceId",
            HelpMessage = "SubnetId")]
        [ValidateNotNullOrEmpty]
        public string SubnetId { get; set; }

        [Parameter(
            Mandatory = true,
            ValueFromPipelineByPropertyName = true,
            ParameterSetName = "SetByResource",
            HelpMessage = "Subnet")]
        public PSSubnet Subnet { get; set; }

        [Parameter(
            Mandatory = false,
            ValueFromPipelineByPropertyName = true,
            ParameterSetName = "SetByResourceId",
            HelpMessage = "PublicIpAddressId")]
        public string PublicIpAddressId { get; set; }

        [Parameter(
            Mandatory = false,
            ValueFromPipelineByPropertyName = true,
            ParameterSetName = "SetByResource",
            HelpMessage = "PublicIpAddress")]
        public PSPublicIpAddress PublicIpAddress { get; set; }

        [Parameter(
            Mandatory = false,
            ValueFromPipelineByPropertyName = true,
            ParameterSetName = "SetByResourceId",
            HelpMessage = "NetworkSecurityGroupId")]
        public string NetworkSecurityGroupId { get; set; }

        [Parameter(
            Mandatory = false,
            ValueFromPipelineByPropertyName = true,
            ParameterSetName = "SetByResource",
            HelpMessage = "NetworkSecurityGroup")]
        public PSNetworkSecurityGroup NetworkSecurityGroup { get; set; }

        [Parameter(
            Mandatory = false,
            ValueFromPipelineByPropertyName = true,
            ParameterSetName = "SetByResourceId",
            HelpMessage = "LoadBalancerBackendAddressPoolId")]
        public List<string> LoadBalancerBackendAddressPoolId { get; set; }

        [Parameter(
            Mandatory = false,
            ValueFromPipelineByPropertyName = true,
            ParameterSetName = "SetByResource",
            HelpMessage = "LoadBalancerBackendAddressPools")]
        public List<PSBackendAddressPool> LoadBalancerBackendAddressPool { get; set; }

        [Parameter(
            Mandatory = false,
            ValueFromPipelineByPropertyName = true,
            ParameterSetName = "SetByResourceId",
            HelpMessage = "LoadBalancerInboundNatRuleId")]
        public List<string> LoadBalancerInboundNatRuleId { get; set; }

        [Parameter(
            Mandatory = false,
            ValueFromPipelineByPropertyName = true,
            ParameterSetName = "SetByResource",
            HelpMessage = "LoadBalancerInboundNatRule")]
        public List<PSInboundNatRule> LoadBalancerInboundNatRule { get; set; }

        [Parameter(
            Mandatory = false,
            ValueFromPipelineByPropertyName = true,
            HelpMessage = "The IpConfiguration name." +
                          "default value: ipconfig1")]
        [ValidateNotNullOrEmpty]
        public string IpConfigurationName { get; set; }

        [Parameter(
            Mandatory = false,
            ValueFromPipelineByPropertyName = true,
            HelpMessage = "The list of Dns Servers")]
        public List<string> DnsServer { get; set; }

        [Parameter(
            Mandatory = false,
            ValueFromPipelineByPropertyName = true,
            HelpMessage = "The Internal Dns name")]
        public string InternalDnsNameLabel { get; set; }

        [Parameter(
            Mandatory = false,
            HelpMessage = "EnableIPForwarding")]
        public SwitchParameter EnableIPForwarding { get; set; }

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

            if (this.IsNetworkInterfacePresent(this.ResourceGroupName, this.Name))
            {
                ConfirmAction(
                    Force.IsPresent,
                    string.Format(Microsoft.Azure.Commands.Network.Properties.Resources.OverwritingResource, Name),
                    Microsoft.Azure.Commands.Network.Properties.Resources.OverwritingResourceMessage,
                    Name,
                    () => CreateNetworkInterface());

                WriteObject(this.GetNetworkInterface(this.ResourceGroupName, this.Name));
            }
            else
            {
                var networkInterface = CreateNetworkInterface();

                WriteObject(networkInterface);
            }
        }

        private PSNetworkInterface CreateNetworkInterface()
        {
            // Get the subnetId and publicIpAddressId from the object if specified
            if (string.Equals(ParameterSetName, Microsoft.Azure.Commands.Network.Properties.Resources.SetByResource))
            {
                this.SubnetId = this.Subnet.Id;

                if (this.PublicIpAddress != null)
                {
                    this.PublicIpAddressId = this.PublicIpAddress.Id;
                }

                if (this.NetworkSecurityGroup != null)
                {
                    this.NetworkSecurityGroupId = this.NetworkSecurityGroup.Id;
                }

                if (this.LoadBalancerBackendAddressPool != null)
                {
                    this.LoadBalancerBackendAddressPoolId = new List<string>();
                    foreach (var bepool in this.LoadBalancerBackendAddressPool)
                    {
                        this.LoadBalancerBackendAddressPoolId.Add(bepool.Id);
                    }
                }

                if (this.LoadBalancerInboundNatRule != null)
                {
                    this.LoadBalancerInboundNatRuleId = new List<string>();
                    foreach (var natRule in this.LoadBalancerInboundNatRule)
                    {
                        this.LoadBalancerInboundNatRuleId.Add(natRule.Id);
                    }
                }
            }

            var networkInterface = new PSNetworkInterface();
            networkInterface.Name = this.Name;
            networkInterface.Location = this.Location;
            networkInterface.EnableIPForwarding = this.EnableIPForwarding.IsPresent;
            networkInterface.IpConfigurations = new List<PSNetworkInterfaceIpConfiguration>();

            var nicIpConfiguration = new PSNetworkInterfaceIpConfiguration();
            nicIpConfiguration.Name = string.IsNullOrEmpty(this.IpConfigurationName) ? "ipconfig1" : this.IpConfigurationName;
            nicIpConfiguration.PrivateIpAllocationMethod = MNM.IpAllocationMethod.Dynamic;

            if (!string.IsNullOrEmpty(this.PrivateIpAddress))
            {
                nicIpConfiguration.PrivateIpAddress = this.PrivateIpAddress;
                nicIpConfiguration.PrivateIpAllocationMethod = MNM.IpAllocationMethod.Static;
            }

            nicIpConfiguration.Subnet = new PSResourceId();
            nicIpConfiguration.Subnet.Id = this.SubnetId;

            if (!string.IsNullOrEmpty(this.PublicIpAddressId))
            {
                nicIpConfiguration.PublicIpAddress = new PSResourceId();
                nicIpConfiguration.PublicIpAddress.Id = this.PublicIpAddressId;
            }

            if (!string.IsNullOrEmpty(this.NetworkSecurityGroupId))
            {
                networkInterface.NetworkSecurityGroup = new PSResourceId();
                networkInterface.NetworkSecurityGroup.Id = this.NetworkSecurityGroupId;
            }

            if (this.LoadBalancerBackendAddressPoolId != null)
            {
                nicIpConfiguration.LoadBalancerBackendAddressPools = new List<PSResourceId>();
                foreach (var bepoolId in this.LoadBalancerBackendAddressPoolId)
                {
                    nicIpConfiguration.LoadBalancerBackendAddressPools.Add(new PSResourceId { Id = bepoolId });
                }
            }

            if (this.LoadBalancerInboundNatRuleId != null)
            {
                nicIpConfiguration.LoadBalancerInboundNatRules = new List<PSResourceId>();
                foreach (var natruleId in this.LoadBalancerInboundNatRuleId)
                {
                    nicIpConfiguration.LoadBalancerInboundNatRules.Add(new PSResourceId { Id = natruleId });
                }
            }

            if (this.DnsServer != null || this.InternalDnsNameLabel != null)
            {
                networkInterface.DnsSettings = new PSNetworkInterfaceDnsSettings();
                if (this.DnsServer != null)
                {
                    networkInterface.DnsSettings.DnsServers = this.DnsServer;
                }
                if (this.InternalDnsNameLabel != null)
                {
                    networkInterface.DnsSettings.InternalDnsNameLabel = this.InternalDnsNameLabel;
                }

            }

            networkInterface.IpConfigurations.Add(nicIpConfiguration);

            var networkInterfaceModel = Mapper.Map<MNM.NetworkInterface>(networkInterface);
            networkInterfaceModel.Type = Microsoft.Azure.Commands.Network.Properties.Resources.NetworkInterfaceType;
            networkInterfaceModel.Tags = TagsConversionHelper.CreateTagDictionary(this.Tag, validate: true);

            this.NetworkInterfaceClient.CreateOrUpdate(this.ResourceGroupName, this.Name, networkInterfaceModel);

            var getNetworkInterface = this.GetNetworkInterface(this.ResourceGroupName, this.Name);

            return getNetworkInterface;
        }
    }
}

 