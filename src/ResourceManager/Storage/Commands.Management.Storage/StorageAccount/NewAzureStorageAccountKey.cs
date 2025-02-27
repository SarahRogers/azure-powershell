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
using Microsoft.Azure.Management.Storage;
using Microsoft.Azure.Management.Storage.Models;

namespace Microsoft.Azure.Commands.Management.Storage
{
    [Cmdlet(VerbsCommon.New, StorageAccountKeyNounStr), OutputType(typeof(StorageAccountKeys))]
    public class NewAzureStorageAccountKeyCommand : StorageAccountBaseCmdlet
    {
        private const string Key1 = "Key1";

        private const string Key2 = "Key2";


        [Parameter(
            Position = 0,
            Mandatory = true,
            ValueFromPipelineByPropertyName = true,
            HelpMessage = "Resource Group Name.")]
        [ValidateNotNullOrEmpty]
        public string ResourceGroupName { get; set; }

        [Parameter(
            Position = 1,
            Mandatory = true,
            ValueFromPipelineByPropertyName = true,
            HelpMessage = "Storage Account Name.")]
        [Alias(StorageAccountNameAlias, AccountNameAlias)]
        [ValidateNotNullOrEmpty]
        public string Name { get; set; }

        [Parameter(
            Position = 2,
            Mandatory = true,
            ValueFromPipelineByPropertyName = true,
            HelpMessage = "Storage Account Key Name.")]
        [ValidateSet(Key1, Key2, IgnoreCase = true)]
        public string KeyName { get; set; }

        protected override void ProcessRecord()
        {
            base.ProcessRecord();

            KeyName keyName = ParseKeyName(this.KeyName);

            var keys = this.StorageClient.StorageAccounts.RegenerateKey(
                this.ResourceGroupName,
                this.Name,
                keyName);

            WriteObject(keys.StorageAccountKeys);
        }

        private static KeyName ParseKeyName(string keyName)
        {
            if (Key1.Equals(keyName, StringComparison.OrdinalIgnoreCase))
            {
                return Microsoft.Azure.Management.Storage.Models.KeyName.Key1;
            }
            if (Key2.Equals(keyName, StringComparison.OrdinalIgnoreCase))
            {
                return Microsoft.Azure.Management.Storage.Models.KeyName.Key2;
            }
            throw new ArgumentOutOfRangeException("keyName");
        }
    }
}
