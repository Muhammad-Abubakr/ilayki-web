# from selenium import webdriver
# from selenium.webdriver.chrome.options import Options
# import time

# # Set up headless mode
# chrome_options = Options()
# chrome_options.add_argument("--headless")

# # Initialize WebDriver in headless mode
# driver = webdriver.Chrome(options=chrome_options)

# # Open the website
# driver.get("http://127.0.0.1:8000")

# test_login()
# test_register()
# test_insert_product()
# test_get_product_details()
# test_delete_product()

print("All tests ran successfully") 

def test_login():
    driver.find_element_by_id("email").send_keys("abubakr@gmail.com")
    driver.find_element_by_id("password").send_keys("123456")

    driver.find_element_by_id("signin").click()

    time.sleep(3)

    assert "dashboard" in driver.current_url.lower()

    driver.quit()


def test_register():
    driver.find_element_by_id("signup").click()

    driver.find_element_by_id("email").send_keys("abubakr2@gmail.com")
    driver.find_element_by_id("password").send_keys("123456")
    driver.find_element_by_id("confirm-password").send_keys("123456")

    driver.find_element_by_id("signup").click()

    time.sleep(3)

    assert "dashboard" in driver.current_url.lower()

    driver.quit()


def test_insert_product():

    driver.find_element_by_id("email").send_keys("abubakr@gmail.com")
    driver.find_element_by_id("password").send_keys("123456")

    driver.find_element_by_id("signin").click()

    time.sleep(3)

    assert "dashboard" in driver.current_url.lower()

    # Navigate to the product insert page
    driver.find_element_by_id("add_product").click()

    driver.find_element_by_id("product_name").send_keys("New Product")
    driver.find_element_by_id("product_price").send_keys("29.99")
    driver.find_element_by_id("product_description").send_keys("This is a new product.")

    driver.find_element_by_id("submit-product").click()

    time.sleep(3)

    assert "product_added" in driver.page_source.lower()

    driver.quit()


def test_get_product_details():
    driver.find_element_by_id("email").send_keys("abubakr@gmail.com")
    driver.find_element_by_id("password").send_keys("123456")

    driver.find_element_by_id("signin").click()

    time.sleep(3)

    assert "dashboard" in driver.current_url.lower()

    driver.find_element_by_id("get_product_details").click()

    driver.find_element_by_css_selector(".product_item:first-child").click()

    time.sleep(3)

    assert "product_details" in driver.page_source.lower()

    driver.quit()



def test_delete_product():
    driver.find_element_by_id("email").send_keys("abubakr@gmail.com")
    driver.find_element_by_id("password").send_keys("123456")

    driver.find_element_by_id("signin").click()

    time.sleep(3)

    driver.find_element_by_id("product_delete_link").click()

    driver.find_element_by_css_selector(".delete_button:first-child").click()

    driver.switch_to.alert.accept()

    time.sleep(3)

    assert "product_deleted" in driver.page_source.lower()

    driver.quit()

