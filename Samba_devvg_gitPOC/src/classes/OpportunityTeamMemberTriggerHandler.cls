public class OpportunityTeamMemberTriggerHandler {

    public void onBeforeInsert(List<OpportunityTeamMember> newOpportunityTeamMembers){}
    
    public void onAfterInsert
    (List<OpportunityTeamMember> newOpportunityTeamMembers, Map<ID, OpportunityTeamMember> newOpportunityTeamMemberMap)
    {
        List<ConnectApi.BatchInput> batchInputs = new List<ConnectApi.BatchInput>();
        List<EntitySubscription> listOfNewFollowers = new List<EntitySubscription>();
        Map<String, String> mapOppIdAndPublicOppId = new Map<String, String>();
        
        for(OpportunityTeamMember oppTM : [SELECT OpportunityId, Opportunity.SMB_OPP_Public_Opportunity_ID__c FROM OpportunityTeamMember 
                                            WHERE Id IN : newOpportunityTeamMemberMap.keySet()])
        {
            if(oppTM.Opportunity.SMB_OPP_Public_Opportunity_ID__c != null)
            mapOppIdAndPublicOppId.put(oppTM.OpportunityId, oppTM.Opportunity.SMB_OPP_Public_Opportunity_ID__c);
        }
        
        for(OpportunityTeamMember oppTM : newOpportunityTeamMembers){
            
            //Creating the list for new feeds on Opportunity, to all the new user adding as Opportunity Team Member.
            batchInputs.add(SMB_Chatter_Helper.createFeedList
            (oppTM.OpportunityId, oppTM.UserId, 
            '  '+System.Label.SMB_New_Opportunity_Team_Member_Message+' (Opportunity Public Id : '+mapOppIdAndPublicOppId.get(oppTM.OpportunityId)+')'));
            
            //Creating the list, so all the new Team Members become follower of corresponding opportunity.
            listOfNewFollowers.add(new EntitySubscription(ParentId=oppTM.OpportunityId, SubscriberId=oppTM.UserId));
        }
        
        if(!Test.isRunningTest() && batchInputs.size()>0)
        SMB_Chatter_Helper.postBulkChatterFeed(batchInputs);

        Database.SaveResult[] srList = database.insert(listOfNewFollowers, false);
            for (Integer indexi=0; indexi<srList.size(); indexi++) {
                Database.SaveResult sr = srList[indexi];
                if (!sr.isSuccess()) {
                    for(Database.Error err : sr.getErrors()) {
                        System.debug('err.getMessage():'+err.getMessage());
                        if (!err.getMessage().contains(Label.SMB_DUPLICATE_VAL_ERR)){
                            insert listOfNewFollowers[indexi];
                        }
                    }
                }
            }
    }
    
    public void onBeforeUpdate
    (List<OpportunityTeamMember> oldOpportunityTeamMembers, List<OpportunityTeamMember> newOpportunityTeamMembers, 
    Map<ID, OpportunityTeamMember> oldOpportunityTeamMemberMap, Map<ID, OpportunityTeamMember> newOpportunityTeamMemberMap){}
    
    public void onAfterUpdate
    (List<OpportunityTeamMember> oldOpportunityTeamMembers, List<OpportunityTeamMember> newOpportunityTeamMembers, 
                Map<ID, OpportunityTeamMember> oldOpportunityTeamMemberMap, Map<ID, OpportunityTeamMember> newOpportunityTeamMemberMap){}
    
    public void onBeforeDelete
    (List<OpportunityTeamMember> oldOpportunityTeamMembers, Map<ID, OpportunityTeamMember> oldOpportunityTeamMemberMap){}
    
    public void onAfterDelete
    (List<OpportunityTeamMember> oldOpportunityTeamMembers, Map<ID, OpportunityTeamMember> oldOpportunityTeamMemberMap){
        
        List<EntitySubscription> subscriptionList = new List<EntitySubscription>();
        Set<String> setOfDeletedTeamMembers = new Set<String>();
        Set<Id> setOfOppIds = new Set<Id>();
                
        for(OpportunityTeamMember oppTM : oldOpportunityTeamMembers){
            setOfDeletedTeamMembers.add(oppTM.OpportunityId+''+oppTM.UserId);
            setOfOppIds.add(oppTM.OpportunityId);
        }
        
        for(EntitySubscription es : [SELECT Id, ParentId, SubscriberId FROM EntitySubscription WHERE ParentId IN : setOfOppIds LIMIT 1000]){
            if(setOfDeletedTeamMembers.contains(es.ParentId+''+es.SubscriberId)){
                subscriptionList.add(new EntitySubscription(Id=es.Id));
            }
        }
        
        delete subscriptionList;
    
    }
    
    public void onUndelete(List<OpportunityTeamMember> newOpportunityTeamMembers){}

}