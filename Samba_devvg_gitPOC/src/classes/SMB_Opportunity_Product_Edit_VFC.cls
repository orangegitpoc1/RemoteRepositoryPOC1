/* Ust-01261 standard edit button of opportunity product replace with 
Vf page SMB_Opportunity_Product_Edit_VFP to look same as Add/Edit button of opportunity product 
Created By : dev support on 02/02/2016
*/

public class SMB_Opportunity_Product_Edit_VFC {

    OpportunityLineItem OLT;

    public SMB_Opportunity_Product_Edit_VFC(ApexPages.StandardController controller) {
      OLT=new OpportunityLineItem();
      
      OLT=(OpportunityLineItem)controller.getRecord();
      system.debug('OLT'+OLT);
      
      OLT=[select id,opportunityid from OpportunityLineItem where id=:OLT.id];
       system.debug('OLT'+OLT.opportunityid);
   
      
    }
    //Action method call from page
    public PageReference PageRedirect_opty() {
        PageReference opPage = new PageReference('/apex/SMBW3_OptyLine_Step1?id='+OLT.opportunityid);
        opPage.setRedirect(true);
      return opPage ;
    }
    
}