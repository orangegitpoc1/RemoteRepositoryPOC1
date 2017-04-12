public with sharing class SMBW3_Opportunity_Spilit_VFC {

    public SMBW3_Opportunity_Spilit_VFC() {
         }
    public opportunity opp{get;set;}
    public string ownersid{get;set;}
    Public list<OpportunitySplit> osCommision{get;set;}
    Public list<OpportunitySplit> osFinance{get;set;}
    public list<oppsplitwrapper> osCommisionwrapper{get;set;}
    public list<oppsplitwrapper> osFinancewrapper{get;set;} 
    public list<oppsplitwrapper> wrapperList{get;set;}
    private list<opportunitysplit> conditionsToBeDeleted ;
    public Integer counter{get;set;}
    public Integer counter1{get;set;} 
    
    public string processlink{get;set;}   
    public Boolean refreshPage {get; set;}
   
    public SMBW3_Opportunity_Spilit_VFC(ApexPages.StandardController controller) {
    refreshPage=false;
    
    this.opp=(Opportunity)Controller.getRecord();
    
    conditionsToBeDeleted =new list<opportunitysplit>();
    id ids=ApexPages.CurrentPage().getparameters().get('id');
    ownersid= [SELECT name,ownerid FROM Opportunity where id=:ids].ownerid;
    
    osFinance=[select id,OpportunityId,A_B_end__c,Split,SplitPercentage,SplitAmount,Finance_Amount__c,Finance_Percent__c,splitNote,SplitTypeId,SplitOwnerId,SplitOwner.firstname,SplitOwner.lastname from OpportunitySplit where OpportunityId=:opp.id and SplitTypeId=:Split__c.getValues('Finance').Split_id__c order By SplitOwner.lastname DESC NULLS LAST ];
    
    osCommision=[select id,OpportunityId,A_B_end__c,Split,SplitPercentage,SplitAmount,Commission_Amount__c,CommissionPercent__c,splitNote,SplitTypeId,SplitOwnerId,SplitOwner.firstname,SplitOwner.lastname from OpportunitySplit where OpportunityId=:opp.id and SplitTypeId=:Split__c.getValues('Commission').Split_id__c order By SplitOwner.lastname DESC NULLS LAST];
   
    osCommisionwrapper= new list<oppsplitwrapper>();
    osFinancewrapper=new list<oppsplitwrapper>(); 
            counter = 0;
            for(OpportunitySplit oppsp : osCommision){
                
               if(oppsp.SplitOwnerId==ownersid){
                   oppsplitwrapper oppWrap = new oppsplitwrapper(oppsp);
                   oppWrap.counterWrap = 0;
                   osCommisionwrapper.add(oppWrap);
               
               }
               else{
                system.debug('counter'+counter);
                oppsplitwrapper oppWrap = new oppsplitwrapper(oppsp);  
                 counter++;              
                oppWrap.counterWrap = counter;
                osCommisionwrapper.add(oppWrap);
                
                
                }
                osCommisionwrapper.sort();
               system.debug('osCommisionwrapper'+osCommisionwrapper); 
            }
                counter1 = 0;
                for(OpportunitySplit oppfinance : osFinance){
                
               
                if(oppfinance.SplitOwnerId==ownersid){
                   oppsplitwrapper oppWrap = new oppsplitwrapper(oppfinance);
                   oppWrap.counterWrap = 0;
                   osFinancewrapper.add(oppWrap);
               
               }
                else{
                system.debug('counter'+counter);
                oppsplitwrapper oppWrap = new oppsplitwrapper(oppfinance);  
                 counter1++;              
                oppWrap.counterWrap = counter1;
                osFinancewrapper.add(oppWrap);
                
                
                }
                osFinancewrapper.sort();
                system.debug('osFinancewrapper'+osFinancewrapper); 
            }

    
    }
    


    
    
    Public PageReference Edit_split()
    {
     pagereference pag=new pagereference('/apex/SMBW3_Edit_Opportunity_Split_VPF?id='+opp.id);
     pag.setRedirect(true);
     return pag;
    }
    
  
    
     public PageReference processLinkClick() {
     PageReference pag=new PageReference ('/'+processlink);
        return pag;
    }
    

    
    
    public class oppsplitwrapper implements Comparable{ 
     public OpportunitySplit oppsplit{get;set;}
     public Integer counterWrap{get;set;}
     public string splitmember{get;set;}
      
      public oppsplitwrapper(OpportunitySplit opsplit){
       this.oppsplit=opsplit;
       this.splitmember=opsplit.SplitOwner.firstname +' '+ opsplit.SplitOwner.lastname;
      }
      
       public Integer compareTo(Object CompareTo) {
         //   return counterWrap.CompareTo(((oppsplitwrapper)ObjToCompare).counterWrap);
            
            oppsplitwrapper compareToRec = (oppsplitwrapper)CompareTo;
            Integer returnValue = 0;
                    if (counterWrap > compareToRec.counterWrap) {
                        returnValue=1;
                    } else if (counterWrap < compareToRec.counterWrap ) {
                        returnValue =-1;
                    }
                  return returnValue;  
                    
        }
 }   


}