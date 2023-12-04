package SeleniumGroup.SeleniumArtifact;

import org.junit.Assert;
import org.openqa.selenium.By;
import org.openqa.selenium.WebDriver;
import org.openqa.selenium.support.ui.WebDriverWait;

public class SignInPage 
{
	WebDriver driver;
	String AdminUserName;
	String AdminUserPassword;
	
	By Username_Input_Field = By.cssSelector("input#Username_Input_Field");
	By Next_Button = By.cssSelector("button[type='submit'][id='Next_Button']");
	By Password_Input_Field = By.cssSelector("input#Password_Input_Field");
	
	public SignInPage(WebDriver driver, String AdminUserName, String AdminUserPassword) {
        this.driver = driver;
        this.AdminUserName = AdminUserName;
        this.AdminUserPassword = AdminUserPassword;
    }
   
	public void adminLogin() {
		
    	driver.findElement(Username_Input_Field).sendKeys(AdminUserName);
    	driver.findElement(Next_Button).click();
        driver.findElement(Password_Input_Field).sendKeys(AdminUserPassword);
        driver.findElement(Next_Button).click();
        Assert.assertEquals("", "");
        
        
    }
}
