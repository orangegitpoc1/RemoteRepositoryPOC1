/* Class created to have logic of trigger 
In this class On insert update and delete of opportunity member update opportunity's OME_BID_Manager__c and OME_Sales_Owner__c
ust-1281 (OME_Sales_Owner functionality)

*/
Public without sharing class SMB_OME_UpdateBIDField_TRG{
    List<Opportunity> OpportunityList = new List<Opportunity>();
    Map<id,Opportunity> MapOpp=new Map<id,Opportunity>();
    Map<id,user> MapUser=new Map<id,user>();
    string OmeBidName;
    string previousSelectedUserRole;
    id currentOppty;
    Set<id> ids=new Set<id>();
    Set<id> Oppids=new Set<id>();
            Public  void OnInsert(List<OpportunityTeamMember> LOTM){
                        for(OpportunityTeamMember OpportunityTeamMemberObj: LOTM){
                                ids.add(OpportunityTeamMemberObj.UserId);            //set of id of opp team member
                                Oppids.add(OpportunityTeamMemberObj.OpportunityId);  //set of id of opportunity
                        }
                        //***********Map of user and opportunity is created to access data in below loops *************
                        
                        if(ids.size()>0){
                            MapUser=new Map<id,user>([Select id,NAME from User where Id IN:ids ]);  
                        }
                        if(Oppids.size()>0){
                            MapOpp=new Map<id,Opportunity>([select id,OME_BID_Manager__c,OME_Sales_Owner__c from Opportunity where id IN:Oppids]);
                        }
                        for(OpportunityTeamMember OpportunityTeamMemberObj: LOTM){
                            if(OpportunityTeamMemberObj.TeamMemberRole =='OME BID MANAGER'){   // if team member is OME BID MANAGER
                                Opportunity opp=MapOpp.get(OpportunityTeamMemberObj.OpportunityId); //using map to get opportunity related to this team member
                                opp.OME_BID_Manager__c=MapUser.get(OpportunityTeamMemberObj.UserId).Name; //assign Ome bid manager using map of user with team member name 
                                //OpportunityList.add(opp);
                                
                            }
                            else if(OpportunityTeamMemberObj.TeamMemberRole =='OME Sales owner'){
                                Opportunity opp=MapOpp.get(OpportunityTeamMemberObj.OpportunityId);
                                opp.OME_Sales_Owner__c=MapUser.get(OpportunityTeamMemberObj.UserId).Name; //assign Ome sales owner using map of user with team member name 
                                
                            }
                        }    
                        
                        update MapOpp.values();
            }
            Public  void OnUpdate(List<OpportunityTeamMember> ListNew,List<OpportunityTeamMember> ListOld,Map<id,OpportunityTeamMember>MapNew){
                        for(OpportunityTeamMember OpportunityTeamMemberObj: ListNew){
                        ids.add(OpportunityTeamMemberObj.UserId);
                        Oppids.add(OpportunityTeamMemberObj.OpportunityId);
                        }
                        //***********Map of user and opportunity is created to access data in below loops *************
                        if(ids.size()>0){
                             MapUser=new Map<id,user>([Select id,NAME from User where Id IN:ids ]); 
                        }
                        if(Oppids.size()>0){
                            MapOpp=new Map<id,Opportunity>([select id,OME_BID_Manager__c,OME_Sales_Owner__c from Opportunity where id IN:Oppids]);
                        }
                    //************** Previous Team member is 'Ome BID manager'and new is not Bid manager so assign OME BID MANAger to null 
                        for(OpportunityTeamMember OpportunityTeamMemberObj: ListOld){
                            if((OpportunityTeamMemberObj.TeamMemberRole =='OME BID MANAGER') && (MapNew.get(OpportunityTeamMemberObj.id).TeamMemberRole!='OME BID MANAGER')){
                                Opportunity opp=MapOpp.get(OpportunityTeamMemberObj.OpportunityId);
                                opp.OME_BID_Manager__c='';
                            
                                
                            }
                    //*********if new team member is Ome bid manager or Ome sales owner  then assign OME BID manager or ome sales owner  with team member         
                            else {
                                if((MapNew.get(OpportunityTeamMemberObj.id).TeamMemberRole=='OME BID MANAGER')){
                                    Opportunity opp=MapOpp.get(OpportunityTeamMemberObj.OpportunityId);
                                    opp.OME_BID_Manager__c=MapUser.get(OpportunityTeamMemberObj.UserId).Name;
                                    
                                }
                            }
                       //************** Previous Team member is 'Ome sales owner'and new is not Bid sales owner  so assign OME BID Manager to null 
                      
                            if((OpportunityTeamMemberObj.TeamMemberRole =='OME Sales owner') && (MapNew.get(OpportunityTeamMemberObj.id).TeamMemberRole!='OME Sales owner')){
                                Opportunity opp=MapOpp.get(OpportunityTeamMemberObj.OpportunityId);
                                opp.OME_Sales_Owner__c='';
                            
                                
                            }
                      //*********if new team member is  Ome sales owner  then assign or ome sales owner  with team member         
                              
                            else {
                                if((MapNew.get(OpportunityTeamMemberObj.id).TeamMemberRole=='OME Sales owner')){
                                    Opportunity opp=MapOpp.get(OpportunityTeamMemberObj.OpportunityId);
                                    system.debug('MapUser'+MapUser);
                                    system.debug('MapUser.get(OpportunityTeamMemberObj.UserId).Name'+OpportunityTeamMemberObj.UserId);
                                    opp.OME_Sales_Owner__c=MapUser.get(OpportunityTeamMemberObj.UserId).Name;
                                    
                                }
                            }
                        }
                
                    update MapOpp.values();
            }
         //************* on delete of Opportunity Team member assign OMe Bid member or OME sales owner to null;    
            Public  void OnDelete(List<OpportunityTeamMember> ListOld){
                        for(OpportunityTeamMember OpportunityTeamMemberObj:ListOld){
                                Oppids.add(OpportunityTeamMemberObj.OpportunityId);
                        }
                        if(Oppids.size()>0){
                            MapOpp=new Map<id,Opportunity>([select id,OME_BID_Manager__c,OME_Sales_Owner__c from Opportunity where id IN:Oppids]);
                        }               
                        for(OpportunityTeamMember OpportunityTeamMemberObj: ListOld){
                            if(OpportunityTeamMemberObj.TeamMemberRole =='OME BID MANAGER'){
                                Opportunity opp=MapOpp.get(OpportunityTeamMemberObj.OpportunityId);
                                opp.OME_BID_Manager__c='';
                                
                            }
                            else if(OpportunityTeamMemberObj.TeamMemberRole =='OME Sales owner'){
                                Opportunity opp=MapOpp.get(OpportunityTeamMemberObj.OpportunityId);
                                opp.OME_Sales_Owner__c='';
                                
                            }
                        }
                
                    update MapOpp.values();
            
            }

}