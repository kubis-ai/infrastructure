def lambda_handler(event, context):

    domain = 'https://kubis.ai'
    accountValidationEndpoint = '/account-verification'

    username = event.get('userName', '')
    name = event['request']['userAttributes'].get('name', '')
    code = event['request'].get('codeParameter', '')

    print(event)

    if event['triggerSource'] == "CustomMessage_SignUp" or "CustomMessage_ResendCode":
        url = domain + accountValidationEndpoint + "?email=" + username + "&code=" + code
        event['response']['emailSubject'] = "Validate your account"
        event['response']['emailMessage'] = "Hi " + name + "!<br><br>" \
                                            "Thank you for signing up!<br>" \
                                            "Please click the link below to validate your account:<br><br>" \
                                            "<a href='" + url + "'>" + \
                                            url + "</a><br><br> " \
                                            "Regards,<br>" \
                                            "Kubis Team" 

    elif event['triggerSource'] == "CustomMessage_ForgotPassword":
        event['response']['emailSubject'] = "Reset your password"
        event['response']['emailMessage'] = "Hi <b>" + username + "</b>!<br>" \
                                            "Click <a href='" + domain + "confirm-password-reset?" \
                                            "identifier=" + username + "&code=" + code + "'>here</a> " \
                                            "to reset your password."

    elif event['triggerSource'] == "CustomMessage_UpdateUserAttribute":
        event['response']['emailSubject'] = "Validate your new email"
        event['response']['emailMessage'] = "Hi <b>" + username + "</b>!<br>" \
                                            "Click <a href='" + domain + "/confirm-email-change?" \
                                            "code=" + code + "'>here</a> " \
                                            "to validate your new email."

    if event['triggerSource'] == "CustomMessage_AdminCreateUser":
        user_attr = event['request'].get('userAttributes', {})
        user_status = user_attr.get('cognito:user_status')
        if user_status == 'FORCE_CHANGE_PASSWORD':
            event['response']['emailSubject'] = "Validate your account"
            event['response']['emailMessage'] = "Hi <b>" + username + "</b>!<br><br>" \
                                                "You recently attempted to signin, but your account is still 'unverified'.<br><br>" \
                                                "Your temporary password is <b>" + code + "</b>.<br><br>" \
                                                "Click <a href='" + domain + \
                "/confirm-account-password-validation'>here</a> to complete account validation."

    return event
