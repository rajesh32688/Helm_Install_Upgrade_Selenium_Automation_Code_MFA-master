package SeleniumGroup.SeleniumArtifact;

import org.junit.Assert;
import org.openqa.selenium.By;
import org.openqa.selenium.WebDriver;

public class InstallationPage {
	WebDriver driver;
	String LDAPAdminGroup;
	String DNS_Name;
	String AdminUserPassword;
	
	public InstallationPage(WebDriver driver, String DNS_Name, String AdminUserPassword){
        this.driver = driver;
        this.AdminUserPassword = AdminUserPassword;
        this.DNS_Name = DNS_Name;
    }
	
	By DB_Registrator_Button = By.id("DB_Registrator_Button");
	By Next_Button = By.id("Next_Button");
	By DNS_Hostname_Input_Field = By.id("DNS_Hostname_Input_Field");
	By Admin_Password_Input_Field = By.id("Admin_Password_Input_Field");
	By Password_Confirmation_Input_Field = By.id("Password_Confirmation_Input_Field");
	By Create_Key_Button = By.id("Create_Key_Button");
	
    public void doInstallAA()
    {
    driver.findElement(DB_Registrator_Button).click();
    driver.findElement(Next_Button).click();
    driver.findElement(DNS_Hostname_Input_Field).clear();
    driver.findElement(DNS_Hostname_Input_Field).sendKeys(DNS_Name);
    driver.findElement(Next_Button).click();
    driver.findElement(Admin_Password_Input_Field).sendKeys(AdminUserPassword);
    driver.findElement(Password_Confirmation_Input_Field).sendKeys(AdminUserPassword);
    driver.findElement(Next_Button).click();
    driver.findElement(Create_Key_Button).click();
    driver.findElement(Next_Button).click();
    //Assert.assertEquals(driver.findElement(By.linkText("Restarting...")).isDisplayed(), true); //Needs to be enhanced
}
}
