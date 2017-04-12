public without sharing class SMBW2_OPP_OverrideOppNew_VFC {

    public Opportunity   oppty          {get;set;}
    public String     opptyOwner        {get;set;}
  //  public date       dateCreatedDateInput  {get;set;}
    public Id accId;
   
    public SMBW2_OPP_OverrideOppNew_VFC(ApexPages.StandardController controller){
        oppty = new Opportunity();
        opptyOwner = userInfo.getName();
     //   dateCreatedDateInput = date.today();
     //   oppty.SMB_Opp_Dummy_CreateDate__c = date.today();
        accId = Apexpages.currentPage().getParameters().get('accid');
        oppty.AccountId =accId;
    }


    public pageReference saveOpp(){

        try{
            Id OpptyOwnerId = [SELECT Id FROM User WHERE Id =: userInfo.getUserId() and IsActive = True LIMIT 1].Id;
            system.debug('++OpptyOwnerId+'+OpptyOwnerId);
            Id RTId = [SELECT Id FROM RecordType WHERE sObjectType ='Opportunity' and DeveloperName = 'Samba_Local_Opportunity' LIMIT 1].Id;
            
            /***************************************START***************************************/
            //Coded by following lines on 5/15/2015 as per UST-01068
             list<SMB_OPP_MustWinVal_Regional__c> custom_set=SMB_OPP_MustWinVal_Regional__c.getall().values();
             Boolean isRegional = false;
            for(SMB_OPP_MustWinVal_Regional__c foropp:custom_set)
            {
                if((';'+oppty.SMB_OPP_Must_Win_level__c+';').contains((';'+foropp.name+';')))
                isRegional = true;
           }
            if(oppty.SMB_OPP_Must_Win_level__c == null)oppty.SMB_OPP_Must_Win_level__c='None';
            if(isRegional )
           oppty.SMB_Opp_Must_Win__c = 'Yes';
           else
           oppty.SMB_Opp_Must_Win__c = 'No';
            /****************************************END*****************************************/
           
            oppty.OwnerId = OpptyOwnerId;
            oppty.RecordTypeId = RTId;
            oppty.StageName = '1 Pre-qualification';
            //oppty.CloseDate = date.today().addDays(30);
            //oppty.CreatedDate = dateCreatedDateInput;
         //   oppty.CreatedDate = oppty.SMB_Opp_Dummy_CreateDate__c; // Ticket 2285 
            insert oppty;
            
            PageReference pageRef = new PageReference('/apex/SMBW2_OPP_ChooseRecordType?oppId=' + oppty.Id);
            return pageRef;
        }
        catch(exception ex){
            if(!ex.getMessage().contains('FIELD_CUSTOM_VALIDATION_EXCEPTION'))
            Apexpages.addMessage(new Apexpages.Message(ApexPages.severity.ERROR, 'Exception Error: ' + ex));
            return null;
        }
         return null; 
    }
    
    public pageReference cancelOpp(){
        PageReference pageRef = new PageReference('/006/o');
        return pageRef;
    }
}