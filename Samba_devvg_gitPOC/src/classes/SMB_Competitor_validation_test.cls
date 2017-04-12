@isTest
Public class SMB_Competitor_validation_test{
 public static List<opportunity> opp=new list<opportunity>();
    public testmethod static void Oninsert(){
        Profile p = [SELECT Id FROM Profile WHERE Name='System Administrator'];
        User u = new User
        (Alias = 'standt', Email='standarduser@testorg.com', EmailEncodingKey='UTF-8', LastName='Testing', 
        LanguageLocaleKey='en_US', LocaleSidKey='en_US', ProfileId = p.Id, TimeZoneSidKey='America/Los_Angeles', 
        UserName='abcdeghijkl@testorg.com', SMB_Bypass_VR__c=true, PAD_BypassTrigger__c=';SMBW3_Opportunity_TR009_OppSplit_TRG;');
        System.runAs(u){
        Test.startTest();
            TestDataCreation.createSplitcommission(1, 'Commission');
            TestDataCreation.createSplitsales(1, 'Sales User SAMBA');
            TestDataCreation.createSplitfinance(1, 'Finance');
            TestDataCreation.createcustomsetting_profile();
            Account acc=TestDataCreation.createAccounts(1)[0];
            Account accul=TestDataCreation.createultimateAccounts(1,acc.id)[0];
            opp=TestDataCreation.createOpportunitiesWithAccount(1,acc.id);
           // opp[0].Partner_Is_available__c=true;
            update Opp[0];
            
            Competitor__c com2=new Competitor__c(SMB_OPCOM_Competitor_Name__c='None',Opportunity__c=Opp[0].id,SMB_OPCOM_Primary__c=false);
            try{
            insert com2;
            }
            catch(Exception e){
            
            }
            
            SMB_Competitor_validation.run=true;
            Competitor__c com1=new Competitor__c(SMB_OPCOM_Competitor_Name__c='None',Opportunity__c=Opp[0].id,SMB_OPCOM_Primary__c=true);
            insert com1;
            
            SMB_Competitor_validation.run=true;
            Competitor__c com3=new Competitor__c(SMB_OPCOM_Competitor_Name__c='None',Opportunity__c=Opp[0].id,SMB_OPCOM_Primary__c=true);
            insert com3;
            
            SMB_Competitor_validation.run=true;
            Competitor__c com4=new Competitor__c(SMB_OPCOM_Competitor_Name__c='None',Opportunity__c=Opp[0].id,SMB_OPCOM_Primary__c=false);
            insert com4;
            
            SMB_Competitor_validation.run=true;
            Competitor__c com5=new Competitor__c(SMB_OPCOM_Competitor_Name__c='None',Opportunity__c=Opp[0].id,SMB_OPCOM_Primary__c=false);
            insert com5;
            
                                  
            SMB_Competitor_validation.run=true;
            com4.SMB_OPCOM_Primary__c=true;
            update com4;
            
            ApexPages.StandardController sc = new ApexPages.StandardController(com4);
            SMB_Competitor_Delete  ComDel = new SMB_Competitor_Delete(sc);
        
            PageReference pageRef = Page.SMB_Competitor_Delete;
            pageRef.getParameters().put('id', String.valueOf(com4.Id));
            Test.setCurrentPage(pageRef);
            ComDel.check();
            ComDel.backfunction();
            
            ApexPages.StandardController sc1 = new ApexPages.StandardController(com5);
            SMB_Competitor_Delete  ComDel1 = new SMB_Competitor_Delete(sc1);
            PageReference pageRef1 = Page.SMB_Competitor_Delete;
            pageRef1.getParameters().put('id', String.valueOf(com5.Id));
            Test.setCurrentPage(pageRef1);
            ComDel1.check();
    
             
       Test.stopTest();    
       }
       
    }
    
    public testmethod static void OnUpdate(){
        Profile p = [SELECT Id FROM Profile WHERE Name='System Administrator'];
        User u = new User
        (Alias = 'standt', Email='standarduser@testorg.com', EmailEncodingKey='UTF-8', LastName='Testing', 
        LanguageLocaleKey='en_US', LocaleSidKey='en_US', ProfileId = p.Id, TimeZoneSidKey='America/Los_Angeles', 
        UserName='abcdeghijkl@testorg.com', SMB_Bypass_VR__c=true, PAD_BypassTrigger__c=';SMBW3_Opportunity_TR009_OppSplit_TRG;');
        System.runAs(u){
        Test.startTest();
            TestDataCreation.createSplitcommission(1, 'Commission');
            TestDataCreation.createSplitsales(1, 'Sales User SAMBA');
            TestDataCreation.createSplitfinance(1, 'Finance');
            TestDataCreation.createcustomsetting_profile();
            opportunity op=new Opportunity(CloseDate=Date.today().addDays(1), Name='Test', StageName='3 Proposal', 
                                        GAM_type__c='Standard GAM', Standard_GAM_Registered__c=true, Amount=10,
                                        CurrentDateTime_OnChange_Of_Registration__c = Datetime.now().addMinutes(-15),
                                        Smb_opportunity_without_partner__c=true,Order_Type__c='New Custome',type='Direct',SMB_OPP_Domains__c='OAB',
                                        SMB_OPP_Pre_qualification_gate__c='GO',SMB_OPP_Pre_qualification_gate_Date__c=Date.today().addDays(3),SMB_OPP_Qualification_gate__c='Go',SMB_OPP_Qualification_gate_Date__c=Date.today().addDays(2));
            insert op;                            
            Competitor__c com6=new Competitor__c(SMB_OPCOM_Competitor_Name__c='None',Opportunity__c=Op.id,SMB_OPCOM_Primary__c=true);
            insert com6;
            
            ApexPages.StandardController sc2 = new ApexPages.StandardController(com6);
            SMB_Competitor_Delete  ComDel2 = new SMB_Competitor_Delete(sc2);
            PageReference pageRef2 = Page.SMB_Competitor_Delete;
            pageRef2.getParameters().put('id', String.valueOf(com6.Id));
            Test.setCurrentPage(pageRef2);
           
            try{
            ComDel2.check();
            }
            catch(Exception e){
            
            }
       }
    }    
    
   
}