@isTest(SeeAllData=true) 
public class SMBW3_Edit_Opportunity_Split_test1{
    static testMethod void insertOpporunity()
    {
        Profile p = [SELECT Id FROM Profile WHERE Name='System Administrator'];
         User u = new User
        (Alias = 'standt', Email='standarduser1@testorg.com', EmailEncodingKey='UTF-8', LastName='Testing1', 
        LanguageLocaleKey='en_US', LocaleSidKey='en_US', ProfileId = p.Id, TimeZoneSidKey='America/Los_Angeles', 
        UserName='abcdeg@testorg.com', SMB_Bypass_VR__c=true,PAD_BypassTrigger__c='');
        
       System.runAs(u){
        Test.startTest();
        account acc=TestDataCreation.createAccounts(1)[0];
        System.assertEquals(acc.name,'Test0');
        account accul=TestDataCreation.createultimateAccounts(1,acc.id)[0];
        opportunity opp=TestDataCreation.createOpportunitiesWithAccount(1,acc.id)[0]; 
       
        ApexPages.StandardController opp_edit = new ApexPages.StandardController(opp);
        PageReference pageRef = Page.SMBW3_Edit_Opportunity_Split_VFP;
        Test.setCurrentPage(pageRef);
        ApexPages.currentPage().getParameters().put('id', opp.id);  
        ApexPages.currentPage().getParameters().put('index', '0'); 
        SMBW3_Edit_Opportunity_Split_VPC testController = new SMBW3_Edit_Opportunity_Split_VPC(opp_edit );
        List<OpportunitySplit> oppSplitList= new List<OpportunitySplit>();
        OpportunitySplitType opsplittype=[SELECT Id,MasterLabel,DeveloperName  FROM OpportunitySplitType WHERE DeveloperName= 'Overlay'][0];
        list<user> us=[SELECT Id,profile.name FROM User where profile.name='Sales User SAMBA' and IsActive=true];
        oppSplitList.add(new OpportunitySplit(OpportunityId=opp.Id,SplitTypeId=opsplittype.id,SplitPercentage=100,CommissionPercent__c=100,A_B_end__c='B End',SplitOwnerId=us[8].id));
        oppSplitList.add(new OpportunitySplit(OpportunityId=opp.Id,SplitTypeId=opsplittype.id,SplitPercentage=70,CommissionPercent__c=70,A_B_end__c='Russia (i)',SplitOwnerId=us[7].id));
        oppSplitList.add(new OpportunitySplit(OpportunityId=opp.Id,SplitTypeId=opsplittype.id,SplitPercentage=70,CommissionPercent__c=70,A_B_end__c='Russia (0)',SplitOwnerId=us[9].id));
        oppSplitList.add(new OpportunitySplit(OpportunityId=opp.Id,SplitTypeId=opsplittype.id,SplitPercentage=70,CommissionPercent__c=70,A_B_end__c='A End',SplitOwnerId=us[3].id));
        oppSplitList.add(new OpportunitySplit(OpportunityId=opp.Id,SplitTypeId=opsplittype.id,SplitPercentage=70,CommissionPercent__c=70,A_B_end__c='BM/BP (DGC)',SplitOwnerId=us[1].id));
        oppSplitList.add(new OpportunitySplit(OpportunityId=opp.Id,SplitTypeId=opsplittype.id,SplitPercentage=70,CommissionPercent__c=70,A_B_end__c='B End',SplitOwnerId=us[2].id));
       
        insert oppSplitList;
      //   oppSplitList.add(new OpportunitySplit(OpportunityId=opp.Id,SplitTypeId=opsplittype.id,SplitPercentage=70,CommissionPercent__c=70,A_B_end__c='Russia (i)',SplitOwnerId=us[10].id));
        OpportunitySplitType opsplittypef=[SELECT Id,MasterLabel,DeveloperName  FROM OpportunitySplitType WHERE DeveloperName = 'Revenue'][0];
       // list<OpportunitySplit> osf=[select id from OpportunitySplit where opportunityid=:Opp.id and SplitTypeId=:opsplittypef.id];
        List<OpportunitySplit> oppSplitListf= new List<OpportunitySplit>();
        oppSplitListf.add(new OpportunitySplit(OpportunityId=opp.id,SplitTypeId=opsplittypef.id,SplitPercentage=70,Finance_Percent__c=70,A_B_end__c='Russia (i)',SplitOwnerId=us[7].id));
     //   oppSplitListf.add(new OpportunitySplit(OpportunityId=opp.id,SplitTypeId=opsplittypef.id,SplitPercentage=70,Finance_Percent__c=70,A_B_end__c='B End',SplitOwnerId=us[2].id));
     //   oppSplitListf.add(new OpportunitySplit(OpportunityId=opp.id,SplitTypeId=opsplittypef.id,SplitPercentage=100,Finance_Percent__c=100,A_B_end__c='A End',SplitOwnerId=us[3].id));
     //   oppSplitListf.add(new OpportunitySplit(OpportunityId=opp.id,SplitTypeId=opsplittypef.id,SplitPercentage=70,Finance_Percent__c=70,A_B_end__c='Russia (0)',SplitOwnerId=us[9].id));
      //  oppSplitListf.add(new OpportunitySplit(OpportunityId=opp.id,SplitTypeId=opsplittypef.id,SplitPercentage=70,Finance_Percent__c=70,A_B_end__c='BM/BP (DGC)',SplitOwnerId=us[11].id));
       
        insert oppSplitListf;
        testController.saveclosecommission();
        SMBW3_Edit_Opportunity_Split_VPC.oppsplitwrapper wrappersplit1= new SMBW3_Edit_Opportunity_Split_VPC.oppsplitwrapper(oppSplitList[1]);
    //  SMBW3_Edit_Opportunity_Split_VPC.oppsplitwrapper wrappersplit2= new SMBW3_Edit_Opportunity_Split_VPC.oppsplitwrapper(oppSplitfin[1]);
        wrappersplit1.compareTo(wrappersplit1);
        testController.addRow();
        testController.addRowFinance();
        testController.removingRow();
        testController.removingRowFinanace();
        testController.saveclosefinance();
        testController.Removesplit(oppSplitList,'commission');
        
        testController.Removesplit(oppSplitListf,'Finance');
    
    }

    }
}