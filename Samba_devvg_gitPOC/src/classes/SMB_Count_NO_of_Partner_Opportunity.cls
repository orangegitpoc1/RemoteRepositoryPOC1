/**************************************************************
Created By:162487
Ust-1335
Cretaed on :2/8/2016
This batch class will run on daily bases .In this if partner added in opportunity then Partner_Is_available__c field will get checked 
and stage greater than 2 then unchecked Smb_opportunity_without_partner__c.

***************************************************************/
global class SMB_Count_NO_of_Partner_Opportunity implements 
    Database.Batchable<sObject> {

   global final String query;
   
   global SMB_Count_NO_of_Partner_Opportunity(String q) {
       query = q;
   }

   global Database.QueryLocator start(Database.BatchableContext BC){
       return Database.getQueryLocator(query);
   }
   
   
   global void execute(Database.BatchableContext BC,List<Opportunity> scope){
    Set<id> Oppids=new Set<id>();
    list<opportunity> Lopp=new list<opportunity>();                                                   //List of Opportunity          
   
    Map<Id,list<OpportunityPartner>> Mapcount=new Map<Id,list<OpportunityPartner>>();                  //map of opportunity id and list of OpportunityPartner
        for(Opportunity oppo:scope){
            Oppids.add(oppo.id);                           //set of Opportunity id
            
        }
        
    if(Oppids.size()>0){
                             
      list<OpportunityPartner> OppPartner=   [SELECT opportunityId,id                                //list of opportunity partner associted with Opportunity id 
                                   FROM OpportunityPartner
                                   WHERE OpportunityId in: Oppids  
                                   ];
                                   
            for(OpportunityPartner Op:OppPartner ){
                   if(op!=null){
                          if(Mapcount.containsKey(op.opportunityId)){                                //puting opportunity id and list of opp partner
                              list<OpportunityPartner> lop=Mapcount.get(op.opportunityId);
                              lop.add(Op);
                              Mapcount.put(op.opportunityid,lop);
                          }
                          else{
                              Mapcount.put(op.opportunityid,new list<OpportunityPartner>{op});
                          }
                   }
               } 
               for(Opportunity opp:scope){
                   if(!(opp.Partner_Is_available__c)&& Mapcount.get(opp.id)!=null ){                            // partner is available is false and map of opp 
                                                                                                               //and partner not equal null
                          opp.Partner_Is_available__c=true;
                               if(opp.Smb_opportunity_without_partner__c){                                    //  Smb_opportunity_without_partner equal to true        
                                      opp.Smb_opportunity_without_partner__c=false;    
                                }
                                Lopp.add(opp);
                    }
                    else if(opp.Partner_Is_available__c && Mapcount.get(opp.id)==null){                    // partner is available is true and map of opp 
                              opp.Partner_Is_available__c=false;                                           //and partner not equal null     
                              if(opp.SMB_OPP_stage_Gam_nb__c>2){
                                    opp.Smb_opportunity_without_partner__c=true;
                               }
                               Lopp.add(opp);
                                                   
                    
                    }
               }                   
        }
      if(lopp.size()>0){
          
          database.update(lopp,false);                                                                    //update opportunity
      }  
               
        
   }

   global void finish(Database.BatchableContext BC){
     
   }
}