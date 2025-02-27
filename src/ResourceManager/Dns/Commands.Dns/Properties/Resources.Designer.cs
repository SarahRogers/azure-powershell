﻿//------------------------------------------------------------------------------
// <auto-generated>
//     This code was generated by a tool.
//     Runtime Version:4.0.30319.0
//
//     Changes to this file may cause incorrect behavior and will be lost if
//     the code is regenerated.
// </auto-generated>
//------------------------------------------------------------------------------

namespace Microsoft.Azure.Commands.Dns.Properties {
    using System;
    
    
    /// <summary>
    ///   A strongly-typed resource class, for looking up localized strings, etc.
    /// </summary>
    // This class was auto-generated by the StronglyTypedResourceBuilder
    // class via a tool like ResGen or Visual Studio.
    // To add or remove a member, edit your .ResX file then rerun ResGen
    // with the /str option, or rebuild your VS project.
    [global::System.CodeDom.Compiler.GeneratedCodeAttribute("System.Resources.Tools.StronglyTypedResourceBuilder", "4.0.0.0")]
    [global::System.Diagnostics.DebuggerNonUserCodeAttribute()]
    [global::System.Runtime.CompilerServices.CompilerGeneratedAttribute()]
    internal class Resources {
        
        private static global::System.Resources.ResourceManager resourceMan;
        
        private static global::System.Globalization.CultureInfo resourceCulture;
        
        [global::System.Diagnostics.CodeAnalysis.SuppressMessageAttribute("Microsoft.Performance", "CA1811:AvoidUncalledPrivateCode")]
        internal Resources() {
        }
        
        /// <summary>
        ///   Returns the cached ResourceManager instance used by this class.
        /// </summary>
        [global::System.ComponentModel.EditorBrowsableAttribute(global::System.ComponentModel.EditorBrowsableState.Advanced)]
        internal static global::System.Resources.ResourceManager ResourceManager {
            get {
                if (object.ReferenceEquals(resourceMan, null)) {
                    global::System.Resources.ResourceManager temp = new global::System.Resources.ResourceManager("Microsoft.Azure.Commands.Dns.Properties.Resources", typeof(Resources).Assembly);
                    resourceMan = temp;
                }
                return resourceMan;
            }
        }
        
        /// <summary>
        ///   Overrides the current thread's CurrentUICulture property for all
        ///   resource lookups using this strongly typed resource class.
        /// </summary>
        [global::System.ComponentModel.EditorBrowsableAttribute(global::System.ComponentModel.EditorBrowsableState.Advanced)]
        internal static global::System.Globalization.CultureInfo Culture {
            get {
                return resourceCulture;
            }
            set {
                resourceCulture = value;
            }
        }
        
        /// <summary>
        ///   Looks up a localized string similar to Are you sure you want to overwrite any existing record set &apos;{0}&apos; of type {1} in zone &apos;{2}&apos;? You will lose any existing records in that record set..
        /// </summary>
        internal static string Confirm_OverwriteRecord {
            get {
                return ResourceManager.GetString("Confirm_OverwriteRecord", resourceCulture);
            }
        }
        
        /// <summary>
        ///   Looks up a localized string similar to Are you sure you want to permanently remove record set &apos;{0}&apos; from zone &apos;{1}&apos;?.
        /// </summary>
        internal static string Confirm_RemoveRecordSet {
            get {
                return ResourceManager.GetString("Confirm_RemoveRecordSet", resourceCulture);
            }
        }
        
        /// <summary>
        ///   Looks up a localized string similar to Are you sure you want to permanently remove zone &apos;{0}&apos;?.
        /// </summary>
        internal static string Confirm_RemoveZone {
            get {
                return ResourceManager.GetString("Confirm_RemoveZone", resourceCulture);
            }
        }
        
        /// <summary>
        ///   Looks up a localized string similar to There already exists a CNAME record in this set. A CNAME record set can only contain one record..
        /// </summary>
        internal static string Error_AddRecordMultipleCnames {
            get {
                return ResourceManager.GetString("Error_AddRecordMultipleCnames", resourceCulture);
            }
        }
        
        /// <summary>
        ///   Looks up a localized string similar to Cannot add a record of type {0} to a record set of type {1}. The types must match..
        /// </summary>
        internal static string Error_AddRecordTypeMismatch {
            get {
                return ResourceManager.GetString("Error_AddRecordTypeMismatch", resourceCulture);
            }
        }
        
        /// <summary>
        ///   Looks up a localized string similar to The ETag property of the {0} object is empty or &quot;*&quot;. In order to perform this operation with optimistic concurrency checks, please set the Etag property (you may need to Get the {0} first). In order to perform the operation without optimistic concurrency checks, please specify the -Overwrite switch. .
        /// </summary>
        internal static string Error_EtagNotSpecified {
            get {
                return ResourceManager.GetString("Error_EtagNotSpecified", resourceCulture);
            }
        }
        
        /// <summary>
        ///   Looks up a localized string similar to Name parameter cannot be used with EndsWith..
        /// </summary>
        internal static string Error_NameAndEndsWith {
            get {
                return ResourceManager.GetString("Error_NameAndEndsWith", resourceCulture);
            }
        }
        
        /// <summary>
        ///   Looks up a localized string similar to Cannot remove a record of type {0} from a record set of type {1}. The types must match..
        /// </summary>
        internal static string Error_RemoveRecordTypeMismatch {
            get {
                return ResourceManager.GetString("Error_RemoveRecordTypeMismatch", resourceCulture);
            }
        }
        
        /// <summary>
        ///   Looks up a localized string similar to Creating empty record set ....
        /// </summary>
        internal static string Progress_CreatingEmptyRecordSet {
            get {
                return ResourceManager.GetString("Progress_CreatingEmptyRecordSet", resourceCulture);
            }
        }
        
        /// <summary>
        ///   Looks up a localized string similar to Removing record set ....
        /// </summary>
        internal static string Progress_RemovingRecordSet {
            get {
                return ResourceManager.GetString("Progress_RemovingRecordSet", resourceCulture);
            }
        }
        
        /// <summary>
        ///   Looks up a localized string similar to Removing zone ....
        /// </summary>
        internal static string Progress_RemovingZone {
            get {
                return ResourceManager.GetString("Progress_RemovingZone", resourceCulture);
            }
        }
        
        /// <summary>
        ///   Looks up a localized string similar to Success!.
        /// </summary>
        internal static string Success {
            get {
                return ResourceManager.GetString("Success", resourceCulture);
            }
        }
        
        /// <summary>
        ///   Looks up a localized string similar to Record set &apos;{0}&apos; was created in zone &apos;{1}&apos;.The record set is empty. Use Add-AzureRMDnsRecordConfig to add {2} records to it and Set-AzureRMDnsRecordSet to save your changes..
        /// </summary>
        internal static string Success_NewRecordSet {
            get {
                return ResourceManager.GetString("Success_NewRecordSet", resourceCulture);
            }
        }
        
        /// <summary>
        ///   Looks up a localized string similar to Zone &apos;{0}&apos; was created in resource group &apos;{1}&apos;. The SOA and authoritative NS records for this zone have been created automatically. Use Get-AzureRMDnsRecordSet to retrieve them.
        /// </summary>
        internal static string Success_NewZone {
            get {
                return ResourceManager.GetString("Success_NewZone", resourceCulture);
            }
        }
        
        /// <summary>
        ///   Looks up a localized string similar to Record added. Use Set-AzureRMDnsRecordSet to save your change to this record set..
        /// </summary>
        internal static string Success_RecordAdded {
            get {
                return ResourceManager.GetString("Success_RecordAdded", resourceCulture);
            }
        }
        
        /// <summary>
        ///   Looks up a localized string similar to Record removed. Use Set-AzureRMDnsRecordSet to save your change to this record set..
        /// </summary>
        internal static string Success_RecordRemoved {
            get {
                return ResourceManager.GetString("Success_RecordRemoved", resourceCulture);
            }
        }
        
        /// <summary>
        ///   Looks up a localized string similar to After you create {2} records in this record set you will be able to query them in DNS using the FQDN &apos;{0}.{1}.&apos;.
        /// </summary>
        internal static string Success_RecordSetFqdn {
            get {
                return ResourceManager.GetString("Success_RecordSetFqdn", resourceCulture);
            }
        }
        
        /// <summary>
        ///   Looks up a localized string similar to Record set &apos;{0}&apos; was removed from zone &apos;{1}&apos;..
        /// </summary>
        internal static string Success_RemoveRecordSet {
            get {
                return ResourceManager.GetString("Success_RemoveRecordSet", resourceCulture);
            }
        }
        
        /// <summary>
        ///   Looks up a localized string similar to Zone &apos;{0}&apos; was removed from resource group &apos;{1}&apos;. The SOA and authoritative NS records for this zone have also been deleted..
        /// </summary>
        internal static string Success_RemoveZone {
            get {
                return ResourceManager.GetString("Success_RemoveZone", resourceCulture);
            }
        }
    }
}
