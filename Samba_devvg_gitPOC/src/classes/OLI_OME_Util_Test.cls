@isTest(SeeAllData=true)
public class OLI_OME_Util_Test {

    public static testMethod void OLI_OME_Util_Test(){  
    	//Create Test Opties
        List<Opportunity> listTestOpty = new List<Opportunity>();
        for(Integer iNbOpty=0; iNbOpty<3; iNbOpty++){
            listTestOpty.add(new Opportunity(CloseDate=Date.today().addDays(1), Name='Test'+iNbOpty
                                        , StageName='1 Pre qualification'
                                        , Amount=10
                                        , currencyIsoCode = 'EUR'
                                        //GAM_type__c='Standard GAM', Standard_GAM_Registered__c=true
                                        //CurrentDateTime_OnChange_Of_Registration__c = Datetime.now().addMinutes(-15)
                                        ));
        }
        insert listTestOpty;
        
    	// create test OLIs using above Opties and whatever product we find (we know we have proudcts in SAMBA
    	// even on a refreshed sbx, so no need to recreate one). Ok, I admit it's ugly, I should have used Test.getStandardPricebookId();
    	// but then I'm lazy and this test is not product dependendant and I'll always will have products at SAMBA
        id PriceBookEntryId = [select id from priceBookEntry where isActive = true and currencyIsoCode = 'EUR' LIMIT 1][0].id;
        List<OpportunityLineItem> listTestOLI = new List<OpportunityLineItem>();
        for(Opportunity oOptyTest : listTestOpty){
            for(Integer iNbOLI=0; iNbOLI<3; iNbOLI++){
	            listTestOLI.add(new OpportunityLineItem(
                     OpportunityId						= oOptyTest.id
                    ,PricebookEntryId					= pricebookEntryId
                    ,One_Off_Charge__c 					= 1
                    ,Term_in_months__c 					= 18
                    ,MRC__c 							= 1
                    ,Quantity							= 1
                    ,UnitPrice							= 1
                    ,OME_OPPPR_Contract_Start_Date__c 	= date.today()
                ));
            }
        }
		insert listTestOLI;

		// Do some test
		test.startTest();
        
        // 1) retrieve OLIs created above
        list<Id> listOptyId = new list<Id>();
        for(Opportunity oOptyTest : listTestOpty){
            listOptyId.add(oOptyTest.id);
        }
        
        list<Id> listOLIId = new list<ID>();
        for (OpportunityLineItem oOLIforTest : [select id,OME_OPPPR_Contract_Start_Date__c, Term_in_months__c, OME_OPPPR_Contract_End_Date__c 
                                         from OpportunityLineItem 
                                         where Opportunity.id in :listOptyId
                                        ])
        {
			listOLIId.add(oOLIforTest.id);
        }
        
        // 2) call method on OLIs list of Ids
		OLI_OME_Util.setEndDate(listOLIId);
        for (OpportunityLineItem oOLI : [select id,OME_OPPPR_Contract_Start_Date__c, Term_in_months__c, OME_OPPPR_Contract_End_Date__c 
                                         from OpportunityLineItem 
                                         where Opportunity.id in :listOptyId
                                        ])
        {
			system.assert(oOLI.OME_OPPPR_Contract_Start_Date__c.addMonths(Integer.valueof(oOLI.Term_in_months__c)).isSameDay(oOLI.OME_OPPPR_Contract_End_Date__c), 'APEX TEST OLI_OME_Util_Test failed, Contract Start Date + Terms not equals to End Date');
        }

		test.stopTest();

    }

}