from auth_manager import AuthenticationManager
from dtos import RegistrationRequest, LoginRequest, RecoveryVerificationRequest
import os

# debug class for login and register, delete before final release!!!


def run_test():
    # Cleanup previous DB run
    if os.path.exists("app_data.db"):
        os.remove("app_data.db")

    print("--- Starting Auth Flow Test ---")
    manager = AuthenticationManager()

    # 1. Register User
    print("\n[Test 1] Register User 'testuser' with email 'test@example.com' and password 'password123'")
    reg_req = RegistrationRequest(username="testuser", email="test@example.com", password="password123", confirm_password="password123")
    reg_res = manager.register_user(reg_req)
    if reg_res.success:
        print(f"PASSED: User registered. ID: {reg_res.user_id}")
        if reg_res.secret_key:
             print(f"PASSED: Secret Key received: {reg_res.secret_key}")
             secret_key = reg_res.secret_key
        else:
             print("FAILED: No secret key returned in registration!")
             sys.exit(1)
    else:
        print(f"FAILED: {reg_res.msg}")
        sys.exit(1)

    # 2. Login Success
    print("\n[Test 2] Login with correct credentials (username)")
    login_req = LoginRequest(username="testuser", password="password123")
    login_res = manager.login(login_req)
    if login_res.success:
        print(f"PASSED: Login successful. Token: {login_res.token}")
        if login_res.secret_key:
            print(f"PASSED: Secret Key received on login: {login_res.secret_key}")
        else:
            print("FAILED: No secret key returned in login!")
            sys.exit(1)
    else:
        print(f"FAILED: {login_res.message}")
        sys.exit(1)

    # 3. Login Failure (Wrong password)
    print("\n[Test 3] Login with WRONG password")
    login_req_fail = LoginRequest(username="testuser", password="wrongpassword")
    login_res_fail = manager.login(login_req_fail)
    if not login_res_fail.success:
        print(f"PASSED: Login failed as expected. Msg: {login_res_fail.message}")
    else:
        print(f"FAILED: Login unexpectedly succeeded!")
        sys.exit(1)

    # 4. Duplicate Email
    print("\n[Test 4] Try to register same email again")
    reg_req_dup_email = RegistrationRequest(username="otheruser", email="test@example.com", password="p", confirm_password="p")
    reg_res_dup = manager.register_user(reg_req_dup_email)
    if not reg_res_dup.success:
        if reg_res_dup.msg == "Email already exists":
            print(f"PASSED: Duplicate email failed as expected. Msg: {reg_res_dup.msg}")
        else:
             print(f"FAILED: Duplicate email failed but wrong message: {reg_res_dup.msg}")
    else:
        print(f"FAILED: Duplicate email registration unexpectedly succeeded!")
        sys.exit(1)

    # 5. Duplicate Username
    print("\n[Test 5] Try to register same username again")
    reg_req_dup_user = RegistrationRequest(username="testuser", email="other@example.com", password="p", confirm_password="p")
    reg_res_dup_u = manager.register_user(reg_req_dup_user)
    if not reg_res_dup_u.success:
        if reg_res_dup_u.msg == "Username already exists":
            print(f"PASSED: Duplicate username failed as expected. Msg: {reg_res_dup_u.msg}")
        else:
             print(f"FAILED: Duplicate username failed but wrong message: {reg_res_dup_u.msg}")
    else:
        print(f"FAILED: Duplicate username registration unexpectedly succeeded!")
        sys.exit(1)

    # 6. Persistence Check
    print("\n[Test 6] Persistence Check (New Manager Instance)")
    manager2 = AuthenticationManager() # Should load from same DB file
    login_req2 = LoginRequest(username="testuser", password="password123")
    login_res2 = manager2.login(login_req2)
    if login_res2.success:
        print(f"PASSED: Login persistence successful.")
    else:
        print(f"FAILED: Persistence check failed. Could not login with new manager instance.")
        sys.exit(1)

    # 7. Recovery Verification
    print("\n[Test 7] Recovery Verification")
    if secret_key: 
        # Success Case
        verify_req = RecoveryVerificationRequest(username="testuser", email="test@example.com", secret_key=secret_key)
        verify_res = manager2.verify_recovery_info(verify_req)
        if verify_res.success:
            print(f"PASSED: Recovery verification successful. Msg: {verify_res.message}")
        else:
            print(f"FAILED: Recovery verification failed unexpectedly. Msg: {verify_res.message}")
            sys.exit(1)

        # Failure Case (Wrong Key)
        verify_req_fail = RecoveryVerificationRequest(username="testuser", email="test@example.com", secret_key="WRONG-KEY")
        verify_res_fail = manager2.verify_recovery_info(verify_req_fail)
        if not verify_res_fail.success:
             print(f"PASSED: Recovery verification failed as expected with wrong key. Msg: {verify_res_fail.message}")
        else:
             print(f"FAILED: Recovery verification succeeded with wrong key!")
             sys.exit(1)
    else:
        print("SKIPPING Test 7: No secret key available from previous steps")

    # 8. Password Change via Recovery
    print("\n[Test 8] Password Change via Recovery")
    if secret_key:
        from dtos import RecoveryChangeRequest # local import
        change_req = RecoveryChangeRequest(username="testuser", secret_key=secret_key, new_password="newpassword123", confirm_password="newpassword123")
        success = manager2.execute_password_recovery(change_req)
        if success:
            print("PASSED: Password changed successfully via recovery.")

            # 9. Login with New Password
            print("\n[Test 9] Login with NEW password")
            login_req_new = LoginRequest(username="testuser", password="newpassword123")
            login_res_new = manager2.login(login_req_new)
            if login_res_new.success:
                print("PASSED: Login with new password successful.")
            else:
                print(f"FAILED: Could not login with new password. Msg: {login_res_new.message}")
                sys.exit(1)
                
            # 10. Login with OLD password (should fail)
            print("\n[Test 10] Login with OLD password (should fail)")
            login_req_old = LoginRequest(username="testuser", password="password123")
            login_res_old = manager2.login(login_req_old)
            if not login_res_old.success:
                print("PASSED: Login with old password failed as expected.")
            else:
                print("FAILED: Login with old password succeeded!")
                sys.exit(1)

        else:
            print("FAILED: execute_password_recovery returned False.")
            sys.exit(1)
    else:
        print("SKIPPING Test 8, 9, 10: No secret key available")

    print("\n--- All Tests Passed ---")

if __name__ == "__main__":
    run_test()
