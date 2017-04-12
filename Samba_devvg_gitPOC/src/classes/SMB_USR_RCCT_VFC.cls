public class SMB_USR_RCCT_VFC { 
    //[15/01/14 OLE UST-01048 WIT-002037 RCCTv2]
    //Controller for managing dependendant RCCT pick list on record page layout
    //The corresponding page is displayed inline in the standard page layout
    //Values for Region pick list are pulled from a custom setting
    //Pick list values for dependent level (CCT) are pulled via SOQL from UserRole table filtered on previous level
    //
    // Methods:
    //  Constructor (with getRecord() top pull information from current object)
    //  gettter and setters for each level of pick list: region, cluster, country,territory

    // declare pick list levels
    public string region      {get;set;}  //store current value input from UI
    public string cluster     {get;set;}
    public string country     {get;set;}
    public string territory   {get;set;}
    public string prevRegion  = ''; //previous value, use to detect if there is a change and therefore force a refresh of sub-levels
    public string prevCluster = '';
    public string prevCountry = '';
    public string sSave       {get;set;} //to be used with javascript if page called in modal window from custom link/button 
                                        //to control save back and refresh to orignal page


    // to store  regions, retrieved from custom setting
    map<string, SMB_Setting_Region__c> mapSMBRegion = SMB_Setting_Region__c.getall();

    // Some region may not be using the suffix naming
    //fixprep region suffix fix
    private string sSuffixRegion  = ''; //' Region';
    private String sSuffixCluster   = ''; //' Cluster';
    private String sSuffixCountry   = ''; //' Country';
    private String sSuffixTerritory = ''; //' Territory';


    //Literal Sectino, first step to localization/translation
    string sNA = 'N/A';
    string sNone = '--none--';

    //private final oRecord for managing current record
    public User oRecord {get;set;}
    public ApexPages.standardcontroller oControl {get;set;}

    //--------------------- Constructor -----------------------------------------------------
    // The extension constructor initializes the private member
    // variable oRecord by using the getRecord method from the standard
    // controller
    public SMB_USR_RCCT_VFC (ApexPages.StandardController stdController) {
        this.oRecord  = (User) stdController.getRecord();
        region      = prevRegion  = (this.oRecord.SMB_Sales_Region__c    == null) ? '' : this.oRecord.SMB_Sales_Region__c;
        cluster     = prevCluster = (this.oRecord.SMB_Sales_Cluster__c   == null) ? '' : this.oRecord.SMB_Sales_Cluster__c ;
        country     = prevCountry = (this.oRecord.SMB_Sales_Country__c   == null) ? '' : this.oRecord.SMB_Sales_Country__c ;
        territory                 = (this.oRecord.SMB_Sales_Territory__c == null) ? '' : this.oRecord.SMB_Sales_Territory__c;
        oControl    = stdController;
        
        sSave       = 'false';  //for controlling save/cancel button from custom link or button
    } // end of SMB_USR_RCCT_VFC

    // Exceptions
    public class RCCTException extends Exception {}
    //throw new RCCTException('You cant do that here');
    //ApexPages.addMessage( new ApexPages.Message(ApexPages.Severity.ERROR, 'my error msg')); 

    //--------------------- Save ------------------------------------------------------
    Public pagereference saveRecord()
    {
        try 
        {
            //wrap the RCCT values in a oRCCT tuple
            RCCTV2_Tuple oRCCT = new RCCTV2_Tuple();
                oRCCT.region    = region;
                oRCCT.cluster   = cluster;
                oRCCT.country   = country;
                oRCCT.territory = territory;
            
            //Ensure consistency for final level (last non null level myst be N/A, 
            // sublevels below N/A must be null, region must not be null, replace --none-- by N/A
            string sReturn = RCCTV2_ROL_Util.enforceNonApplicable(oRCCT);

            //interrupt dialog if any issue
            if (sReturn == null)      {sSave = 'false'; throw new RCCTException('RCCTV2_ROL_Util.enforceNonApplicable() returns null, contact Administrator');}
            if (sReturn.length() > 0) {sSave = 'false'; throw new RCCTException('Error: ' + sReturn + ' while saving on RCCTV2_ROL_Util.enforceNonApplicable() contact Administrator');}

            // noexception above, continue
            this.oRecord.SMB_Sales_Region__c      = oRCCT.region;
            this.oRecord.SMB_Sales_Cluster__c     = oRCCT.cluster;
            this.oRecord.SMB_Sales_Country__c     = oRCCT.country;
            this.oRecord.SMB_Sales_Territory__c   = oRCCT.territory;
            
            sSave = 'true';
            //update this.oRecord; //note:  OLE 15/01/12 control.save() works better with test class, something to investigate....
            oControl.save();
            return null;
        } catch (Exception e) 
        {
            ApexPages.addMessage(new ApexPages.message(ApexPages.severity.ERROR,'Exception : '+e));
            return null;
        }
    } //end of saveRecord


    // region level pick list management ----------------------------------------------------------
    public List<SelectOption> getRegions()
    {
        //init list to store options
        List<SelectOption> options = new List<SelectOption> { new SelectOption('',sNone) };
        
        // fill option list from list region pulled from Custom setting
        List<SMB_Setting_Region__c> listSMBRegion = mapSMBRegion.values();
        listSMBRegion.sort();

        boolean bFoundRegion = false;

        for ( SMB_Setting_Region__c thisSMBRegion : listSMBRegion)
        {
            //options.add (new SelectOption(thisSMBRegion.SMB_ROL_Name__c, thisSMBRegion.SMB_ROL_Name__c));   
            //Fix Prepare fixprep region suffix fix
            if (thisSMBRegion.SMB_ROL_Has_Suffix__c) 
            {
                sSuffixRegion = ' Region';
            } else 
            {
                sSuffixRegion = '';
            }
            options.add (new SelectOption(thisSMBRegion.SMB_ROL_Name__c.remove(sSuffixRegion), thisSMBRegion.SMB_ROL_Name__c.remove(sSuffixRegion)));   

        }

        // reset level below if region is null
        if(region == null || region == '' || region == sNone
        ) 
        {
            cluster = country = territory = null;
        } 

        //check if region has changed
        if (region != null)
        {
            if (!prevRegion.equals(region)) // there has been a change, let's force a reset of levels below
            {
                cluster = country = territory = null;
                prevRegion = region;
            }

        }

        // Close with sNA
        options.add (new SelectOption(sNA, sNA));                        
        //debug only
        //options.add (new SelectOption('', 'PrevClu:' + prevCluster + ' currentClu:' + cluster ));                        
        
        return options;
    } //end of getRegions
        
    
    
    
    
    
    // cluster level pick list management -----------------------------------------------------------
    public List<SelectOption> getClusters()
    {
        //List to contains values for cluster level 
        List<SelectOption> options = new List<SelectOption>();

        //region has been reset, reset levels below (cluster itself is reset by the rerender)
        if(   region == null || region   == '' || region     == sNone || region     == sNA
          )
        {
            country = territory = null;
            return options;
        }
        
        //If region is not using the suffixed (' Cluster', ' Country', ' Territory') naming convention then set 
        //suffixes to ''. Note that we only need to do this at cluster level, region context will remain the same
        //for country and territory down below
        try 
        {
            
            boolean bRegionHasSuffix = mapSMBRegion.get(region + sSuffixRegion).SMB_ROL_Has_Suffix__c;
            
            if (bRegionHasSuffix) 
            {
                sSuffixCluster    = ' Cluster';
                sSuffixCountry    = ' Country';
                sSuffixTerritory  = ' Territory';
            } else 
                
            {
                sSuffixCluster    = '';
                sSuffixCountry    = '';
                sSuffixTerritory  = '';
            }
            
        } catch (Exception e) 
        {
            /* Too strong, just reste region
            throw new RCCTException(
            'Error 10 in class SMB_CPG_RCCT_VFC while searching region in SMB Setting Region custom setting' 
            +' Either the record contains an invalid region or the custom setting is missing a valid region.'
            + 'Contact Administrator' 
            ); 
            */
            cluster = null;

        }
        
        
        //if another cluster has been selected then reset sub levels
        if (cluster != null)
        {
            if (!prevCluster.equals(cluster)) //change detected, reset sublevels
            {
                //debug
                //options.add (new SelectOption('', 'RESET Co+T PrevClu:' + prevCluster + ' currentClu:' + cluster ));                        
                country = territory = null;
                prevCluster = cluster;
            }
        }
        
        // search for dependant values, if any 
        if (region != null) 
        {    
            // look for current region children, excluding Support, Presale and Account branches
            list<UserRole> listClusterRole = RCCTV2_ROL_Util.listRCCTChildren(region + sSuffixRegion, '');
            if (listClusterRole != null)
            {
                if ( !listClusterRole.isEmpty() ) 
                {
                    options.add (new SelectOption(sNone, sNone));                        
                    // loop on children cluster
                    for (UserRole thisClusterRole : listClusterRole) 
                    {
                        // role from db are suffixed with sSuffixRegion, sSuffixCLuster, etc.... RCCT are not, so we remove
                        // the suffix before comparing or adding to RCCT selection list (note the space before suffix)
                        options.add (new SelectOption(thisClusterRole.name.remove(sSuffixCLuster), thisClusterRole.name.remove(sSuffixCLuster)));                            
                    }
                }
            }
            else
            {
                //debug only
                //options.add (new SelectOption('yapacluster','yapacluster'));
            }
        }


        // Close with sNA
        options.add (new SelectOption(sNA, sNA));                        

        return options;
    } //end of getClusters   


    // country level ----------------------------------------------------------------------
    public List<SelectOption> getCountries()
    {
        //List to contains values for country level 
        List<SelectOption> options = new List<SelectOption>();

        //reset sub level if level above have been reset
        if(   region    == null || region   == '' || region  == sNone || region == sNA
           || cluster   == null || cluster  == '' || cluster == sNone || cluster == sNA
          )
        {
            territory = null;
            return options;
        }
                
        if (country != null)
        {
                
            if (!prevCountry.equals(country)) //change detected, reset sublevel
            {
                territory = null;
                prevCountry = country;
            }
        }
        // search for dependant values, if any 
        if (cluster != null) 
        {
            // look for current region children
            // We need to add suffix sSuffixCLuster since roles are stored with suffix in db
            list<UserRole> listCountryRole = RCCTV2_ROL_Util.listRCCTChildren(cluster + sSuffixCLuster, '');
            if (listCountryRole != null) 
            {
                if ( !listCountryRole.isEmpty() ) 
                {
                    options.add (new SelectOption(sNone, sNone));                        
                    // loop on children cluster
                    for (UserRole thisCountryRole : listCountryRole) 
                    {
                        options.add (new SelectOption(thisCountryRole.name.remove(sSuffixCountry), thisCountryRole.name.remove(sSuffixCountry)));                            
                    }
                }
            }
            else
            {
                //options.add (new SelectOption('yapacountry','yapacountry'));
            }
        }

        // Close with sNA
        options.add (new SelectOption(sNA, sNA));                        

        return options;
        
    } //end of getCountries
        
    // terrritory level ----------------------------------------------------------------------
    public List<SelectOption> getTerritories()
    {
        //List to contains values for country level 
        List<SelectOption> options = new List<SelectOption>();

        /*
         * 
        try 
        {
        } catch (Exception e) 
        {
            ApexPages.addMessage(new ApexPages.message(ApexPages.severity.ERROR,'Exception : '+e));
        }
        */

        // reset from above, let's return an empty choice list
        if(   region  == null || region  == '' || region  == sNone|| region == sNA
           || cluster == null || cluster == '' || cluster == sNone|| cluster == sNA
           || country == null || country == '' || country == sNone|| country == sNA
          )
        {
            return options;
        }
        
        // search for dependant values, if any 
        if (country != null) 
        {
            // look for current region children
            list<UserRole> listTerritoryRole = RCCTV2_ROL_Util.listRCCTChildren(country + sSuffixCountry, '');
            if (listTerritoryRole != null) 
            {
                if ( !listTerritoryRole.isEmpty() ) 
                {
                     options.add (new SelectOption(sNone, sNone));                        
                     // loop on children country
                     for (UserRole thisTerritoryRole : listTerritoryRole) 
                    {
                        options.add (new SelectOption(thisTerritoryRole.name.remove(sSuffixTerritory), thisTerritoryRole.name.remove(sSuffixTerritory)));                            
                    }
                }
            }
            else
            {
                //options.add (new SelectOption('apaterr','apaterr'));
            }
        }
            
        // Close with sNA
        options.add (new SelectOption(sNA, sNA));                        

        return options;  
    } //end of getTerritories

    //enforceNonApplicable(region, cluster, country, territory);


}