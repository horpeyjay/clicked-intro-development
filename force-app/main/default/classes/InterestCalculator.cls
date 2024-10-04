public with sharing class InterestCalculator {
    //declare variables here
    boolean isSimpleInterest;
    decimal interestAmount;

    public decimal InterestCal (string name, decimal p, decimal r, decimal tf, boolean si){
        this.isSimpleInterest = si;
        if ( isSimpleInterest == true){
            this.interestAmount = (p * r * tf)/100;
            system.debug('The customer with the name ' + name + ' has an interest amount of ' + interestAmount);
            return interestAmount;
        }else{
            decimal culmulativeInterest = 0;
            for (integer i = 1; i <= tf; i++){
                this.interestAmount  = (p * r)/100;
                p += this.interestAmount;
                system.debug('The prinicipal for ' + i + ' year(s) is ' + p);
                system.debug('The interest for ' + i + ' year(s) is ' + this.interestAmount);
                culmulativeInterest += this.interestAmount;
                system.debug('The culmulative interest for ' + i + ' year(s) is ' + culmulativeInterest);
            }
            system.debug('The customer ' + name + ' has an culmulative interest amount of ' + culmulativeInterest);
            return interestAmount;
        }        
    }
}