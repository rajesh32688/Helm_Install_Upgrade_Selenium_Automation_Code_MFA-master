package SeleniumGroup.SeleniumArtifact;

import org.junit.Assert;
import org.openqa.selenium.By;
import org.openqa.selenium.WebDriver;

public class RepositoryPage {
	WebDriver driver;
	String LDAPAdminGroup;
	
	public RepositoryPage(WebDriver driver, String LDAPAdminGroup){
        this.driver = driver;
        this.LDAPAdminGroup = LDAPAdminGroup;
    }
	
	By Repositories = By.cssSelector("i[title='Repositories']");
	By LOCAL_Edit = By.xpath("//a[@id='LOCAL_Edit']");
	By FULL_ADMINS = By.xpath("//*[contains(text(),'FULL ADMINS')]");
	By Enter_Members_FULL_ADMINS = By.cssSelector("input[id='Enter_Members_FULL ADMINS']");
	By Select_LDAPAdminGroup = By.xpath("//div[@class='panel-body visible']/form[1]/div[1]/div[1]/span[1]/span[1]/div[1][@class='tt-dataset-datums']/span[1]/div[1]/p[1]/strong[@class='tt-highlight'][contains(text(),"+LDAPAdminGroup+")]"); 
	// Above will send null only instead of LDAPAdminGroup string but still it is working
	By Save_FULL_ADMINS =  By.cssSelector("button[type='submit'][id='Save_FULL ADMINS']");
    
    public void assignFullAdminRole()
    {
    driver.findElement(Repositories).click();
    driver.findElement(LOCAL_Edit).click();
	driver.findElement(FULL_ADMINS).click();
	driver.findElement(Enter_Members_FULL_ADMINS).sendKeys(LDAPAdminGroup);
	driver.findElement(Select_LDAPAdminGroup).click();
	driver.findElement(Save_FULL_ADMINS).click();
	Assert.assertEquals(driver.findElement(By.xpath("//span[@id='Remove_"+LDAPAdminGroup+"']")).getAttribute("class"), "btn btn-sm btn-default btn-delete");
}
}
