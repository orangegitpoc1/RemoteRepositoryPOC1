@isTest(SeeAllData=true)
private class PADTest{
  static testMethod void myUnitTest(){
    Test.startTest();
    
    Boolean bCanTrigger = PAD.canTrigger('ByPass');
    
    Test.stopTest();
  }
}