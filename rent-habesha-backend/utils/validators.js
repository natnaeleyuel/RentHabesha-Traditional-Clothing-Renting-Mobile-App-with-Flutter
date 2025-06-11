import emailValidator from 'deep-email-validator';

async function isEmailValid(email) {
    return emailValidator.validate(email)
}

export default isEmailValid;