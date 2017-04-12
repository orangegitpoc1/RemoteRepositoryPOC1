public class OpportunityTriggerHandler {
    
    public static Boolean runOnlyOnce = true;
    
    public void OnBeforeInsert(List<Opportunity> newOpportunities){}
    
    public void OnAfterInsert(List<Opportunity> newOpportunities, Map<ID, Opportunity> newOpportunityMap){}
    
    public void OnBeforeUpdate(List<Opportunity> oldOpportunities, List<Opportunity> newOpportunities, 
    Map<ID, Opportunity> oldOpportunityMap, Map<ID, Opportunity> newOpportunityMap){
        //UST-01246: Display error when no partners are added and Opportunity without checkbox is unchecked - START
        //Don't run code if OpportunityTrigger.validatePartners is bypassed in Bypass Trigger of current user
         if(PAD.canTrigger('OpportunityTrigger.validatePartners')){
            //Consider only Opportunities which went to Stage>2 from 1st or 2nd Stage
            List<Opportunity> newOpportunitiesToValidate=new List<Opportunity>();

            for (Opportunity currNewOpp: newOpportunities){
                if (currNewOpp.SMB_OPP_stage_nb__c>2){
                    newOpportunitiesToValidate.add(newOpportunityMap.get(currNewOpp.id));
                }
            }

            //Validate these opportunities
            validatePartners(newOpportunities, newOpportunitiesToValidate, newOpportunityMap);
        }
        //UST-01246 - END
        
        //UST-01249: To validate Parent Opportunity ID is pointing to some already existing Opportunity
        if(PAD.canTrigger('OpportunityTrigger.validatePublicOppID')){
            validatePublicOppID(newOpportunities, newOpportunityMap);
        }

    }
    
    public void OnAfterUpdate(List<Opportunity> oldOpportunities, List<Opportunity> newOpportunities, 
                                Map<ID, Opportunity> oldOpportunityMap, Map<ID, Opportunity> newOpportunityMap)
    {
        List<ConnectApi.BatchInput> batchInputs = new List<ConnectApi.BatchInput>();
        String amountFieldLabel = Schema.Opportunity.fields.Amount.getDescribe().getLabel();
        
        List<Messaging.SingleEmailMessage> mailList = new List<Messaging.SingleEmailMessage>();
        List<EmailTemplate> templateList = [SELECT Id, HtmlValue, Subject FROM EmailTemplate WHERE name = 'SMB_Opp_Old_Owner_Notification' limit 1];
        
        for(Opportunity opp : newOpportunities)
        {
            
            if(opp.Amount != oldOpportunityMap.get(opp.Id).Amount)
            {
                if(OpportunityAfterUpdateHelper.addchatterFeedOnAmountChange
                    (opp.Amount, oldOpportunityMap.get(opp.Id).Amount))
                {
                    String message = ' changed '+amountFieldLabel+' from '+opp.CurrencyIsoCode+' '+oldOpportunityMap.get(opp.Id).Amount+
                                        ' to '+opp.CurrencyIsoCode+' '+opp.Amount;
                    if(oldOpportunityMap.get(opp.Id).Amount == null){
                        message = ' changed '+amountFieldLabel+' from a blank value to '+opp.CurrencyIsoCode+' '+opp.Amount;
                    }                                        
                    batchInputs.add(SMB_Chatter_Helper.createFeedList
                    (opp.Id, null, message));
                }
            }
            
            
            if(opp.OwnerId != oldOpportunityMap.get(opp.Id).OwnerId)
            {
                String subject = templateList[0].Subject.replace('{!Opportunity.Name}', opp.Name);
                String bdy = templateList[0].HtmlValue;
                bdy = bdy.replace('{!Opportunity.Name}', opp.Name);
                bdy = bdy.replace('{!Opportunity.Id}', opp.Id);
                bdy = bdy.replace('{!URL}', OpportunityAfterUpdateHelper.getURL());                                
                mailList.add(SendingEmailHelper.processEmail(oldOpportunityMap.get(opp.Id).OwnerId, subject, bdy, null, null));
            }
            
        }
        
        if(batchInputs.size()>0){
            SMB_Chatter_Helper.postBulkChatterFeed(batchInputs);
        }
        if(mailList.size()>0){
            Messaging.sendEmail(mailList);
        }
        
        OpportunityTriggerHandler.runOnlyOnce = false;
    }
    
    public void OnBeforeDelete(List<Opportunity> oldOpportunities, Map<ID, Opportunity> oldOpportunityMap){}
    
    public void OnAfterDelete(List<Opportunity> oldOpportunities, Map<ID, Opportunity> oldOpportunityMap){}
    
    public void OnUndelete(List<Opportunity> newOpportunities){}
    
    //UST-01246: Display error when no partners are added and Opportunity without checkbox is unchecked
    public void validatePartners(List<Opportunity> newOpportunities, List<Opportunity> newOpportunitiesToValidate, Map<ID, Opportunity> newOpportunityMap){
        //Get no of partners in each Opportunity about to be updated/inserted
        List<AggregateResult> oppPartners = [select OpportunityId, count(id) noOfPartners from OpportunityPartner where OpportunityId IN :newOpportunities GROUP BY OpportunityId];

        Map<Id, Integer> partnerCounts=new Map<Id, Integer>();
        for (AggregateResult ar: oppPartners){
            partnerCounts.put((Id)ar.get('OpportunityId'), (Integer)ar.get('noOfPartners'));
        }
        
        //Check for all Opportunites if 'Opportunity without Partner' is checked even when Partners are added 
        for (Opportunity currOpp: newOpportunities){
            //Add error if checkbox 'Opportunity without Partner' is checked even when Partners are added
            if (partnerCounts.keySet().contains(currOpp.Id) && currOpp.Smb_opportunity_without_partner__c==true){
                    currOpp.addError(Label.SMB_Checked_With_Partner);
            }
        }

        //Check for Stage changed Opportunities if they don't ave any partners and checkbox 'Opportunity without Partner' is also unchecked
        for (Opportunity currOpp: newOpportunitiesToValidate){
            //Add error if checkbox 'Opportunity without Partner' is also unchecked
            if (!partnerCounts.keySet().contains(currOpp.Id) && currOpp.Smb_opportunity_without_partner__c==false){
                    currOpp.addError(Label.SMB_No_Partner);
            }
        }
    }
    
    public void validatePublicOppID(List<Opportunity> newOpportunities, Map<ID, Opportunity> newOpportunityMap){
    //SMB_OPP_Parent_Opportunity_ID__c, SMB_OPP_Public_Opportunity_ID__c
      Map<String, List<Opportunity>> parentOppToOppMap=new Map<String, List<Opportunity>>();
      for (Opportunity opp: newOpportunities) {
        if (opp.SMB_OPP_Parent_Opportunity_ID__c!=null && opp.SMB_OPP_Parent_Opportunity_ID__c!=''){
            if (!parentOppToOppMap.keySet().contains(opp.SMB_OPP_Parent_Opportunity_ID__c)){
                parentOppToOppMap.put(opp.SMB_OPP_Parent_Opportunity_ID__c, new List<Opportunity>());
            }
                parentOppToOppMap.get(opp.SMB_OPP_Parent_Opportunity_ID__c).add(opp);
        }
      }
      
      List<Opportunity> parentOpps=[select SMB_OPP_Public_Opportunity_ID__c from Opportunity where SMB_OPP_Public_Opportunity_ID__c IN :parentOppToOppMap.keySet()];
      Set<String> parentpublicIDs=new Set<String>();
      for (Opportunity parentOpp: parentOpps){
          parentpublicIDs.add(parentOpp.SMB_OPP_Public_Opportunity_ID__c);
      }
      
      for (String publicId: parentOppToOppMap.keySet()) {
        if (!parentpublicIDs.contains(publicId)){
            for (Opportunity opp: parentOppToOppMap.get(publicId)) {
                opp.SMB_OPP_Parent_Opportunity_ID__c.addError(Label.SMB_Invalid_ParentOppID);
            }
        }
      }
      
    }
    
}