/*
Orange id :162487
created on :26/7/2016
UST-01262 In this we are validating primary competitor , there will one primary competitor in Opportunity , if we add more than one then it will check and keep one primary
competitor 
use by Trigger SMB_Primary_Competitor  

*/
public Class SMB_Competitor_validation{
    Set<id> OppId=new set<id>();                                            // set of id of opportunity
    Set<id> cid=new set<id>();                                              //set of id of competitor
    Map<id,Competitor__c> MapCompetitor=new Map<id,Competitor__c>();        //map of competitor     
    list<Competitor__c> listcompetitor=new list<Competitor__c >();        //list of competitor
    public static boolean run = true;
    public static boolean runOnce(){                                            // this function is to ensure this trigger run only once 
    if(run){
     run=false;
     return true;
    }else{
        return run;
    }
    }
    /*
    ***********************************************************************************
    function:onInsert
    purpose : insert competitor and validate  uniqueness of competitor in opportunity 
    ***********************************************************************************/
    
    public void onInsert(List<Competitor__c> newCompetitor){                             
        for(Competitor__c c:newCompetitor){
               OppId.add(c.Opportunity__c); 
               cid.add(c.id);    
        }
        list<Competitor__c> Listcomp=[select id,Opportunity__c,SMB_OPCOM_Primary__c from Competitor__c where Opportunity__c IN:OppId 
                                        and SMB_OPCOM_Primary__c =true and Id NOT IN:cid];      // get  list of primary competitor 
        
        if(Listcomp.size()>0){
                for(Competitor__c c:Listcomp){
                    MapCompetitor.put(c.Opportunity__c,c);                                  // map of opportunity and competitor 
                }
       }
       
       
       for(Competitor__c c:newCompetitor){
       
           if(MapCompetitor.get(c.Opportunity__c)!=null && c.SMB_OPCOM_Primary__c){                     // if competitor is primary and there is another primary competitor
                                                                                                         //       then make that competitor as non primary
               Competitor__c co=new Competitor__c(id=MapCompetitor.get(c.Opportunity__c).id); 
               co.SMB_OPCOM_Primary__c=false;
               listcompetitor.add(co);
           }
           else if(MapCompetitor.get(c.Opportunity__c)==null && !(c.SMB_OPCOM_Primary__c)){         // if no primary competitor then set competitor as primary                
              c.addError(System.Label.SMB_Competior_Primary_Mandatory);                             // error :One primary competitor is mandatory
           
           }
           
       }
       if(listcompetitor.size()>0){
           update listcompetitor;                                                               // update competitor list
       }
    }
    /*
    ***********************************************************************************
    function:onupdate
    purpose : update competitor and validate  uniqueness of competitor in opportunity 
    ***********************************************************************************/
     public void onUpdate(List<Competitor__c> newCompetitor){
       for(Competitor__c c:newCompetitor){
             OppId.add(c.Opportunity__c); 
             cid.add(c.id);    
        }
        list<Competitor__c> Listcomp=[select id,Opportunity__c,SMB_OPCOM_Primary__c from Competitor__c where Opportunity__c IN:OppId 
                                        and SMB_OPCOM_Primary__c =true and Id NOT IN:cid];      // get  list of primary competitor 
        
        if(Listcomp.size()>0){
                for(Competitor__c c:Listcomp){
                    MapCompetitor.put(c.Opportunity__c,c);                                      // map of opportunity and competitor 
                }
       }
       system.debug('----MapCompetitor---' + MapCompetitor);
       for(Competitor__c c:newCompetitor){
        if(MapCompetitor.get(c.Opportunity__c)!=null && c.SMB_OPCOM_Primary__c){                    // if competitor is primary and there is another primary competitor
               Competitor__c co=new Competitor__c(id=MapCompetitor.get(c.Opportunity__c).id);     //       then make that competitor as non primary
               co.SMB_OPCOM_Primary__c=false;
               listcompetitor.add(co);
               
           }
        if(MapCompetitor != null && MapCompetitor.size() > 0 && MapCompetitor.get(c.Opportunity__c)==null && !(c.SMB_OPCOM_Primary__c)){                                          // if no primary competitor then set competitor as primary 
             c.addError(System.Label.SMB_Competior_Primary_Mandatory);                                                             // error :One primary competitor is mandatory
        }
        
         
       }    
   
       if(listcompetitor.size()>0){
           update listcompetitor;                                                                  // update competitor list                  
       }
     
     }
  }