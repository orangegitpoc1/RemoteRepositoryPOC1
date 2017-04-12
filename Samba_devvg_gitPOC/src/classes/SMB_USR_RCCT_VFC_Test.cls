@isTest(SeeAllData=true)
//[15/01/14 OLE UST-01048 WIT-002037 RCCTv2]
public class SMB_USR_RCCT_VFC_Test {

    public static testMethod void myUnitTest(){      
      
        Profile p = [SELECT Id FROM Profile WHERE Name='Standard User']; 
        User oUser = new User(
             Alias = 'ZZZZ'
            ,Email='standarduser@kmail.testorg.com'
            ,EmailEncodingKey='UTF-8'
            ,LastName='ZZZZ432_TEST'
            ,LanguageLocaleKey='en_US'
            ,LocaleSidKey='en_US'
            ,ProfileId = p.Id
            ,TimeZoneSidKey='America/Los_Angeles'
            ,UserName='standarduser@kmail.testorg.com'
            ,SMB_Sales_Region__c ='N/A'
            ,SMB_Sales_Cluster__c = ''
            ,SMB_Sales_Country__c = ''
            ,SMB_Sales_Territory__c = ''
        );

      
      
      
    Test.startTest();
    ApexPages.StandardController scTest = new ApexPages.standardController(oUser);
    SMB_USR_RCCT_VFC             ecTest = new SMB_USR_RCCT_VFC(scTest);

    /*
 
    List<SelectOption> listSelectRegions     = ecTest.getRegions(); //new List<SelectOption> ();
    List<SelectOption> listSelectClusters    = ecTest.getClusters();
    List<SelectOption> listSelectCountries   = ecTest.getCountries();
    List<SelectOption> listSelectTerritories = ecTest.getTerritories();
    ecTest.region       = 'Region';
    ecTest.cluster      = 'Cluster';
    ecTest.country      = 'country';
    ecTest.territory    = 'territory';
    ecTest.prevRegion   = 'differentRegion';
    ecTest.prevCluster  = 'differentCluster';
    ecTest.prevCountry  = 'differentRegion';
    */
    

    // Let's check if we find regions
    List<SelectOption> listSelectRegions     = ecTest.getRegions(); //new List<SelectOption> ();
    system.assert((listSelectRegions != null), 'ecTest.getRegions() fails to return any region');
    if ( listSelectRegions != null)
    {
        //check > 1 because first value is '--none'
        system.assert((listSelectRegions.size() > 1), 
               'ecTest.getRegions() returns 0 region from Custom Setting SMB Setting Region');
        // let's test on first region returned
        ecTest.region = listSelectRegions[1].getLabel();
    }   
    

    // let's see if we get some cluster values
    List<SelectOption> listSelectClusters    = ecTest.getClusters(); //no arg, ecTest.region is used for filtering
    system.assert((listSelectClusters != null), 'ecTest.getClusters() fails to return any cluster');
    if ( listSelectClusters != null)
    {
        system.assert((listSelectClusters.size() >=0), 'ecTest.getClusters() returns 0 cluster ');
        if  (listSelectClusters.size() == 1) 
        {
            // if only one value it should be N/A
            system.assertEquals ('N/A', listSelectClusters[0].getLabel(), 'ecTest.getClusters() returns a single value which is not N/A');
        }
        //let's test with the first value returned
        ecTest.cluster = listSelectClusters[1].getLabel();
    }   
    
    // let's see if we get some country values
    List<SelectOption> listSelectCountries    = ecTest.getCountries(); //no arg, ecTest.cluster is used for filtering
    system.assert((listSelectCountries != null), 'ecTest.getCountries() fails to return any country');
    if ( listSelectCountries != null)
    {
        system.assert((listSelectClusters.size() >=0), 'ecTest.getCountries() returns 0 country ');
        if  (listSelectCountries.size() == 1) 
        {
            // if only one value it should be N/A
            system.assertEquals ('N/A', listSelectCountries[0].getLabel(), 'ecTest.getCountries() returns a single value which is not N/A');
        }
        //let's test with the first value returned
        ecTest.country = listSelectCountries[1].getLabel();
    }   

    
    // finally let's see if we find any country
    //     List<SelectOption> listSelectTerritories = ecTest.getTerritories();
    // let's see if we get some country values
    List<SelectOption> listSelectTerritories    = ecTest.getTerritories(); //no arg, ecTest.cluster is used for filtering
    system.assert((listSelectTerritories != null), 'ecTest.getTerritories() fails to return any country');
    if ( listSelectTerritories != null)
    {
        system.assert((listSelectClusters.size() >=0), 'ecTest.getTerritories() returns 0 country ');
        if  (listSelectTerritories.size() == 1) 
        {
            // if only one value it should be N/A
            system.assertEquals ('N/A', listSelectTerritories[0].getLabel(), 'ecTest.getTerritories() returns a single value which is not N/A');
        }
        //let's test with the first value returned
        ecTest.country = listSelectTerritories[1].getLabel();
    }   
        
    //some brut force test to go through dummy cases
    ecTest.country      = 'country';
    ecTest.territory    = 'territory';
    ecTest.prevRegion   = 'differentRegion';
    ecTest.prevCluster  = 'differentCluster';
    ecTest.prevCountry  = 'differentRegion';
    listSelectTerritories = ecTest.getTerritories();
 
            
    ecTest.region       = 'Region';
    ecTest.cluster      = 'Cluster';
    ecTest.country      = 'Country';
    ecTest.territory    = 'territory';
    ecTest.prevRegion   = 'Region';
    ecTest.prevCluster  = 'Cluster';
    ecTest.prevCountry  = 'country';
 
    listSelectRegions     = ecTest.getRegions(); //new List<SelectOption> ();
    listSelectClusters    = ecTest.getClusters();
    listSelectCountries   = ecTest.getCountries();
    listSelectTerritories = ecTest.getTerritories();

    ecTest.region       = '--none--';
    ecTest.cluster      = '--none--';
    ecTest.country      = '--none--';
    ecTest.territory    = '--none--';
    ecTest.prevRegion   = 'Region';
    ecTest.prevCluster  = 'Cluster';
    ecTest.prevCountry  = 'country';
 
    listSelectRegions     = ecTest.getRegions(); //new List<SelectOption> ();
    listSelectClusters    = ecTest.getClusters();
    listSelectCountries   = ecTest.getCountries();
    listSelectTerritories = ecTest.getTerritories();
       
    ecTest.region       = 'N/A';
    ecTest.cluster      = 'N/A';
    ecTest.country      = 'N/A';
    ecTest.territory    = 'N/A';
    ecTest.prevRegion   = 'Region';
    ecTest.prevCluster  = 'Cluster';
    ecTest.prevCountry  = 'country';
 
    listSelectRegions     = ecTest.getRegions(); //new List<SelectOption> ();
    listSelectClusters    = ecTest.getClusters();
    listSelectCountries   = ecTest.getCountries();
    listSelectTerritories = ecTest.getTerritories();

    
    ecTest.saveRecord();
    
    Test.stopTest();
  }
}