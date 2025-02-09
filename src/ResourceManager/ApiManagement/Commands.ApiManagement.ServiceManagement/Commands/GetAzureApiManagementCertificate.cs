﻿//  
// Copyright (c) Microsoft.  All rights reserved.
// 
//  Licensed under the Apache License, Version 2.0 (the "License");
//  you may not use this file except in compliance with the License.
//  You may obtain a copy of the License at
//    http://www.apache.org/licenses/LICENSE-2.0
// 
//  Unless required by applicable law or agreed to in writing, software
//  distributed under the License is distributed on an "AS IS" BASIS,
//  WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
//  See the License for the specific language governing permissions and
//  limitations under the License.

namespace Microsoft.Azure.Commands.ApiManagement.ServiceManagement.Commands
{
    using System;
    using System.Collections.Generic;
    using System.Management.Automation;
    using System.Runtime.InteropServices;
    using Microsoft.Azure.Commands.ApiManagement.ServiceManagement.Models;

    [Cmdlet(VerbsCommon.Get, "AzureRMApiManagementCertificate", DefaultParameterSetName = GetAll)]
    [OutputType(typeof(IList<PsApiManagementCertificate>))]
    public class GetAzureApiManagementCertificate : AzureApiManagementCmdletBase
    {
        private const string GetAll = "Get all certificates";
        private const string GetById = "Get certificate by ID";

        [Parameter(
            ValueFromPipelineByPropertyName = true, 
            Mandatory = true, 
            HelpMessage = "Instance of PsApiManagementContext. This parameter is required.")]
        [ValidateNotNullOrEmpty]
        public PsApiManagementContext Context { get; set; }

        [Parameter(
            ParameterSetName = GetById,
            ValueFromPipelineByPropertyName = true, 
            Mandatory = true, 
            HelpMessage = "Identifier of the certificate. If specified will find certificate by the identifier. This parameter is required. ")]
        public String CertificateId { get; set; }

        public override void ExecuteApiManagementCmdlet()
        {
            switch (ParameterSetName)
            {
                case GetAll:
                    var certificates = Client.CertificateList(Context);
                    WriteObject(certificates, true);
                    break;
                case GetById:
                    var certificate = Client.CertificateById(Context, CertificateId);
                    WriteObject(certificate);
                    break;
                default:
                    throw new InvalidOperationException(string.Format("Parameter set name '{0}' is not supported.", ParameterSetName));
            }
        }
    }
}
