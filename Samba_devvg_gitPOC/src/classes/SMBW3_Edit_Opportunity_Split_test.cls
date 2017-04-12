@isTest 
public class SMBW3_Edit_Opportunity_Split_test{

    static testMethod void insertOpporunity()
    {
    
        Id parentRoleId = TestDataCreation.createUserRoles(1, null)[0].Id;
        TestDataCreation.createUsers(1, System.Label.Sales_Operation_SAMBA, System.Label.User_Frequency_1day, parentRoleId);
        
        Id roleId = TestDataCreation.createUserRoles(1, parentRoleId)[0].Id;
        Id userId = TestDataCreation.createUsers(1, System.Label.Sales_User_SAMBA, System.Label.User_Frequency_1day, roleId)[0].Id;
        //Profile p = [SELECT Id FROM Profile WHERE Name='System Administrator'];
        Profile p = [SELECT Id FROM Profile WHERE Name='Sales User SAMBA'];
        
        User u = new User
        (Alias = 'standt', Email='standarduser1@testorg.com', EmailEncodingKey='UTF-8', LastName='Testing1', 
        LanguageLocaleKey='en_US', LocaleSidKey='en_US', ProfileId = p.Id, TimeZoneSidKey='America/Los_Angeles', 
        UserName='abcdeg@testorg.com', SMB_Bypass_VR__c=true,PAD_BypassTrigger__c='');
        
       System.runAs(u){
       Test.startTest();
        list<SMBW3_Edit_Opportunity_Split_VPC.oppsplitwrapper> wrapper= new list<SMBW3_Edit_Opportunity_Split_VPC.oppsplitwrapper>();
        TestDataCreation.createSplitcommission(1, 'Commission');
        TestDataCreation.createSplitsales(1, 'Sales User SAMBA');
        TestDataCreation.createSplitfinance(1, 'Finance');
           account acc=TestDataCreation.createAccounts(1)[0];
           System.assertEquals(acc.name,'Test0');
           account accul=TestDataCreation.createultimateAccounts(1,acc.id)[0];
           opportunity opp=TestDataCreation.createOpportunitiesWithAccount(1,acc.id)[0];
     //   opportunity oppc=TestDataCreation.createOpportunities(1)[0];
     //   opportunity oppf=TestDataCreation.createOpportunities(1)[0];
        list<OpportunitySplit> oppSplit = TestDataCreation.createOppSplitcommission(2, opp.id);
       // OpportunitySplit oppSplitcomm = TestDataCreation.createOppSplitcommission(1, opp.id)[0];
        list<OpportunitySplit> oppSplitfin = TestDataCreation.createOppSplitfinance(3, opp.id);
        list<OpportunitySplit> oppSplitf= new list<OpportunitySplit>();
        list<OpportunitySplit> oppSplitc= new list<OpportunitySplit>();
         oppSplitf.addAll(oppSplitfin);
         oppSplitc.addAll(oppSplit );
      //   oppSplit[0].A_B_end__c='Russia (i)';
      //   update oppSplit[0];
       
       ApexPages.StandardController opp_edit = new ApexPages.StandardController(opp);
       PageReference pageRef = Page.SMBW3_Edit_Opportunity_Split_VFP;
       Test.setCurrentPage(pageRef);
       ApexPages.currentPage().getParameters().put('id', opp.id);  
       ApexPages.currentPage().getParameters().put('index', '0'); 
        
      SMBW3_Edit_Opportunity_Split_VPC testController = new SMBW3_Edit_Opportunity_Split_VPC(opp_edit );
    /* testController.Removesplit();
     for(opportunitysplit op : oppSplit){
     SMBW3_Edit_Opportunity_Split_VPC.oppsplitwrapper wrappersplit= new SMBW3_Edit_Opportunity_Split_VPC.oppsplitwrapper(op);
         wrapper.add(wrappersplit);
     }
     */
     SMBW3_Edit_Opportunity_Split_VPC.oppsplitwrapper wrappersplit1= new SMBW3_Edit_Opportunity_Split_VPC.oppsplitwrapper(oppSplit[1] );
    //  SMBW3_Edit_Opportunity_Split_VPC.oppsplitwrapper wrappersplit2= new SMBW3_Edit_Opportunity_Split_VPC.oppsplitwrapper(oppSplitfin[1]);
     wrappersplit1.compareTo(wrappersplit1);
      
      testController.addRow();
      testController.addRowFinance();
      testController.removingRow();
     
    //  testController.savecommission();
    //  testController.saveFinance();
       testController.check=true;
      testController.saveclosecommission();
    //  testController.upadteFinancesplit();
      testController.addRow();
      testController.removingRowFinanace();
      testController.saveclosefinance();
      
      testController.Removesplit(oppSplitc,'commission');
      testController.Removesplit(oppSplitf,'Finance');
     Test.stopTest();
    }
    }
    
  /*   static testMethod void catchtOpporunity()
    {
       Id parentRoleId = TestDataCreation.createUserRoles(1, null)[0].Id;
        TestDataCreation.createUsers(1, System.Label.Sales_Operation_SAMBA, System.Label.User_Frequency_1day, parentRoleId);
        
        Id roleId = TestDataCreation.createUserRoles(1, parentRoleId)[0].Id;
        Id userId = TestDataCreation.createUsers(1, System.Label.Sales_User_SAMBA, System.Label.User_Frequency_1day, roleId)[0].Id;
        //Profile p = [SELECT Id FROM Profile WHERE Name='System Administrator'];
        Profile p = [SELECT Id FROM Profile WHERE Name='Sales User SAMBA'];
        
        User u = new User
        (Alias = 'standt', Email='standarduser1@testorg.com', EmailEncodingKey='UTF-8', LastName='Testing2', 
        LanguageLocaleKey='en_US', LocaleSidKey='en_US', ProfileId = p.Id, TimeZoneSidKey='America/Los_Angeles', 
        UserName='abcdeg@testorg.com', SMB_Bypass_VR__c=true);
        
       System.runAs(u){
       Test.startTest();
        opportunity opp=TestDataCreation.createOpportunities(1)[0];
        OpportunitySplit oppSplitcomm = TestDataCreation.createOppSplitcommission(1, opp.id)[0];
      //  OpportunitySplit oppSplitcomm1 = TestDataCreation.createOppSplitcommission(1, opp.id)[0];
    
    }

}

*/

}