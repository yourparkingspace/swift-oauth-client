//
//  TestStrings.swift
//  
//
//  Created by Jack Nicholson Colley on 28/04/2021.
//

import Foundation

class TestStrings {
    static let oAuthTokenResponse = """
        {
          "token_type": "Bearer",
          "expires_in": 31536000,
          "access_token": "eyJ0eXAiOiJKV1QiLCJhbGciOiJSUzI1NiIsImp0aSI6Ijg1Y2ZlNzM5Y2U5MGIyYjUzMzQ2NTJmMDk0NmE3MWE3MWU3MGQ3NGU2ZTQxN2QyNGJlMTIyZTM2ZWExZDExODMxNTFmNzI1ODgxOGU0YWMwIn0.eyJhdWQiOiIxODIyYjdkNmRlZGRjOTQzZDEyZDAwODc3OTM2MzU3ZCIsImp0aSI6Ijg1Y2ZlNzM5Y2U5MGIyYjUzMzQ2NTJmMDk0NmE3MWE3MWU3MGQ3NGU2ZTQxN2QyNGJlMTIyZTM2ZWExZDExODMxNTFmNzI1ODgxOGU0YWMwIiwiaWF0IjoxNjEzMTE3OTk0LCJuYmYiOjE2MTMxMTc5OTQsImV4cCI6MTY0NDY1Mzk5NCwic3ViIjoiMjk3ODc2Iiwic2NvcGVzIjpbXX0.mDiQBX-M52kWy0UyY6wrPwICZ_CH1_dbB_oFbzl6eNSaN2HjyvqLirpQ2lWyhlGTKtkyRQ0m1966PWLvdCrCZRVyOBMII_gICZO8KI7pJGCFueczA1X7_gX4K6RCxbpS01uLSJZk1-z1c-SJSQyXUBfT2JFJk0MXcc2jd6UDp-NYy_QnBVS-G-NS6GHO9IfL1ihE9DR-iy98-7GZ1S_roMS_R21XxYY8h-ZYdO31n1SWF38rj1jAyXcZqXS7UNZgou81AcFJlF-cZPRdrUi8l7wMHnyhwGGBLDdmz4QjCDaMwJxd_U6bCbtDA4hAw6tkAcFe7mpTqgrXRrn9rNVYCqvvv_B0R6Ooa22Hxwim8LVQGbzVbQYiOKZox1p4zoP-qTIv2jGTjioukIlDMkC5ifKNNYO1WXY2K07xqIKIxwaJTRzNY6Ib9VJwcoONi0SFGWBu92yFnSnsIg3-v8wQYa8Wc5JU_MHZYowM7ubR8GiXZ_uHpPpUshOAWA64jdQswaXpJ7ZuOTMrLaXvtMbc0IXfonWuhKXlJMQh5SQ1xLjPnjyTD2PXXCK3V2DlZazMv3otjUkUQT2WQ2mqFdLlN8r73mifop3Cme2H-j7DVx_VUTyCZSeO_nLCqM-SXktUA8crEH5KYF-5mCqN-5i16QGiXq9NuaOAU1phY5dt6Uk",
          "refresh_token": "def50200be6602a702483fc76cc4cc832afea9ffe77bb9d698effb229a9401b5ef5776a91df6de4d15b9ed9170ade2b96f82e1551ea3a34d65c9d6a03b96804f50fbadc7cbb9a07e076db05304c0d145ef8bda96265aa521abc4b6259327a27d4c236ec1e103bc09201119bd4edfb53e47df863abef9efb81240f1fbf60cf3b15a320bf177745338565acfc2d0cd008b40d577a3695a487bf230c50a6e1b9fdfd63996afe3d1b20faeb9391d04d948b27c306e42d685f799dced4f881f805a274176cfab0e957b152da9c33752d1ae0a339ea675a1a1d8023fe45061814b80db7da152b8059e031bfb8c49a7cc1ae3eeba8ad779abbecec85e3bd17754554356ea4196cfecd68bc0007d26676f58e6d7e3d5f93bca00ec26166a1ad9bc03a3679ac19f3b81992e4642421b096ddd60a05abe25e0556439c8b15413f31d00be05daa8782ebd580a874b43b66cb33f0b4607de99dafe7f4b719216bfd660e8559435e6ecc28bbb5b27eeaad2015e0a0cd485737ee9065d00e6d42a4f4a7d7a5142ee9993806e"
        }

        """

    static let oAuthTokenResponseExpired = """
        {
          "token_type": "Bearer",
          "expires_in": -60,
          "access_token": "eyJ0eXAiOiJKV1QiLCJhbGciOiJSUzI1NiIsImp0aSI6Ijg1Y2ZlNzM5Y2U5MGIyYjUzMzQ2NTJmMDk0NmE3MWE3MWU3MGQ3NGU2ZTQxN2QyNGJlMTIyZTM2ZWExZDExODMxNTFmNzI1ODgxOGU0YWMwIn0.eyJhdWQiOiIxODIyYjdkNmRlZGRjOTQzZDEyZDAwODc3OTM2MzU3ZCIsImp0aSI6Ijg1Y2ZlNzM5Y2U5MGIyYjUzMzQ2NTJmMDk0NmE3MWE3MWU3MGQ3NGU2ZTQxN2QyNGJlMTIyZTM2ZWExZDExODMxNTFmNzI1ODgxOGU0YWMwIiwiaWF0IjoxNjEzMTE3OTk0LCJuYmYiOjE2MTMxMTc5OTQsImV4cCI6MTY0NDY1Mzk5NCwic3ViIjoiMjk3ODc2Iiwic2NvcGVzIjpbXX0.mDiQBX-M52kWy0UyY6wrPwICZ_CH1_dbB_oFbzl6eNSaN2HjyvqLirpQ2lWyhlGTKtkyRQ0m1966PWLvdCrCZRVyOBMII_gICZO8KI7pJGCFueczA1X7_gX4K6RCxbpS01uLSJZk1-z1c-SJSQyXUBfT2JFJk0MXcc2jd6UDp-NYy_QnBVS-G-NS6GHO9IfL1ihE9DR-iy98-7GZ1S_roMS_R21XxYY8h-ZYdO31n1SWF38rj1jAyXcZqXS7UNZgou81AcFJlF-cZPRdrUi8l7wMHnyhwGGBLDdmz4QjCDaMwJxd_U6bCbtDA4hAw6tkAcFe7mpTqgrXRrn9rNVYCqvvv_B0R6Ooa22Hxwim8LVQGbzVbQYiOKZox1p4zoP-qTIv2jGTjioukIlDMkC5ifKNNYO1WXY2K07xqIKIxwaJTRzNY6Ib9VJwcoONi0SFGWBu92yFnSnsIg3-v8wQYa8Wc5JU_MHZYowM7ubR8GiXZ_uHpPpUshOAWA64jdQswaXpJ7ZuOTMrLaXvtMbc0IXfonWuhKXlJMQh5SQ1xLjPnjyTD2PXXCK3V2DlZazMv3otjUkUQT2WQ2mqFdLlN8r73mifop3Cme2H-j7DVx_VUTyCZSeO_nLCqM-SXktUA8crEH5KYF-5mCqN-5i16QGiXq9NuaOAU1phY5dt6Uk"
        }
        """

    static let oAuthTokenResponseExpiredWithRefresh = """
        {
          "token_type": "Bearer",
          "expires_in": -60,
          "access_token": "eyJ0eXAiOiJKV1QiLCJhbGciOiJSUzI1NiIsImp0aSI6Ijg1Y2ZlNzM5Y2U5MGIyYjUzMzQ2NTJmMDk0NmE3MWE3MWU3MGQ3NGU2ZTQxN2QyNGJlMTIyZTM2ZWExZDExODMxNTFmNzI1ODgxOGU0YWMwIn0.eyJhdWQiOiIxODIyYjdkNmRlZGRjOTQzZDEyZDAwODc3OTM2MzU3ZCIsImp0aSI6Ijg1Y2ZlNzM5Y2U5MGIyYjUzMzQ2NTJmMDk0NmE3MWE3MWU3MGQ3NGU2ZTQxN2QyNGJlMTIyZTM2ZWExZDExODMxNTFmNzI1ODgxOGU0YWMwIiwiaWF0IjoxNjEzMTE3OTk0LCJuYmYiOjE2MTMxMTc5OTQsImV4cCI6MTY0NDY1Mzk5NCwic3ViIjoiMjk3ODc2Iiwic2NvcGVzIjpbXX0.mDiQBX-M52kWy0UyY6wrPwICZ_CH1_dbB_oFbzl6eNSaN2HjyvqLirpQ2lWyhlGTKtkyRQ0m1966PWLvdCrCZRVyOBMII_gICZO8KI7pJGCFueczA1X7_gX4K6RCxbpS01uLSJZk1-z1c-SJSQyXUBfT2JFJk0MXcc2jd6UDp-NYy_QnBVS-G-NS6GHO9IfL1ihE9DR-iy98-7GZ1S_roMS_R21XxYY8h-ZYdO31n1SWF38rj1jAyXcZqXS7UNZgou81AcFJlF-cZPRdrUi8l7wMHnyhwGGBLDdmz4QjCDaMwJxd_U6bCbtDA4hAw6tkAcFe7mpTqgrXRrn9rNVYCqvvv_B0R6Ooa22Hxwim8LVQGbzVbQYiOKZox1p4zoP-qTIv2jGTjioukIlDMkC5ifKNNYO1WXY2K07xqIKIxwaJTRzNY6Ib9VJwcoONi0SFGWBu92yFnSnsIg3-v8wQYa8Wc5JU_MHZYowM7ubR8GiXZ_uHpPpUshOAWA64jdQswaXpJ7ZuOTMrLaXvtMbc0IXfonWuhKXlJMQh5SQ1xLjPnjyTD2PXXCK3V2DlZazMv3otjUkUQT2WQ2mqFdLlN8r73mifop3Cme2H-j7DVx_VUTyCZSeO_nLCqM-SXktUA8crEH5KYF-5mCqN-5i16QGiXq9NuaOAU1phY5dt6Uk",
          "refresh_token": "def50200be6602a702483fc76cc4cc832afea9ffe77bb9d698effb229a9401b5ef5776a91df6de4d15b9ed9170ade2b96f82e1551ea3a34d65c9d6a03b96804f50fbadc7cbb9a07e076db05304c0d145ef8bda96265aa521abc4b6259327a27d4c236ec1e103bc09201119bd4edfb53e47df863abef9efb81240f1fbf60cf3b15a320bf177745338565acfc2d0cd008b40d577a3695a487bf230c50a6e1b9fdfd63996afe3d1b20faeb9391d04d948b27c306e42d685f799dced4f881f805a274176cfab0e957b152da9c33752d1ae0a339ea675a1a1d8023fe45061814b80db7da152b8059e031bfb8c49a7cc1ae3eeba8ad779abbecec85e3bd17754554356ea4196cfecd68bc0007d26676f58e6d7e3d5f93bca00ec26166a1ad9bc03a3679ac19f3b81992e4642421b096ddd60a05abe25e0556439c8b15413f31d00be05daa8782ebd580a874b43b66cb33f0b4607de99dafe7f4b719216bfd660e8559435e6ecc28bbb5b27eeaad2015e0a0cd485737ee9065d00e6d42a4f4a7d7a5142ee9993806e"
        }
        """

    static let oAuthTokenResponseMalformed = """
        {
          "token_type": "Bearer",
          "expires_in": 3600,
        }
        """

    static let oAuthTokenResponseNoRefresh = """
        {
          "token_type": "Bearer",
          "expires_in": 31536000,
          "access_token": "eyJ0eXAiOiJKV1QiLCJhbGciOiJSUzI1NiIsImp0aSI6Ijg1Y2ZlNzM5Y2U5MGIyYjUzMzQ2NTJmMDk0NmE3MWE3MWU3MGQ3NGU2ZTQxN2QyNGJlMTIyZTM2ZWExZDExODMxNTFmNzI1ODgxOGU0YWMwIn0.eyJhdWQiOiIxODIyYjdkNmRlZGRjOTQzZDEyZDAwODc3OTM2MzU3ZCIsImp0aSI6Ijg1Y2ZlNzM5Y2U5MGIyYjUzMzQ2NTJmMDk0NmE3MWE3MWU3MGQ3NGU2ZTQxN2QyNGJlMTIyZTM2ZWExZDExODMxNTFmNzI1ODgxOGU0YWMwIiwiaWF0IjoxNjEzMTE3OTk0LCJuYmYiOjE2MTMxMTc5OTQsImV4cCI6MTY0NDY1Mzk5NCwic3ViIjoiMjk3ODc2Iiwic2NvcGVzIjpbXX0.mDiQBX-M52kWy0UyY6wrPwICZ_CH1_dbB_oFbzl6eNSaN2HjyvqLirpQ2lWyhlGTKtkyRQ0m1966PWLvdCrCZRVyOBMII_gICZO8KI7pJGCFueczA1X7_gX4K6RCxbpS01uLSJZk1-z1c-SJSQyXUBfT2JFJk0MXcc2jd6UDp-NYy_QnBVS-G-NS6GHO9IfL1ihE9DR-iy98-7GZ1S_roMS_R21XxYY8h-ZYdO31n1SWF38rj1jAyXcZqXS7UNZgou81AcFJlF-cZPRdrUi8l7wMHnyhwGGBLDdmz4QjCDaMwJxd_U6bCbtDA4hAw6tkAcFe7mpTqgrXRrn9rNVYCqvvv_B0R6Ooa22Hxwim8LVQGbzVbQYiOKZox1p4zoP-qTIv2jGTjioukIlDMkC5ifKNNYO1WXY2K07xqIKIxwaJTRzNY6Ib9VJwcoONi0SFGWBu92yFnSnsIg3-v8wQYa8Wc5JU_MHZYowM7ubR8GiXZ_uHpPpUshOAWA64jdQswaXpJ7ZuOTMrLaXvtMbc0IXfonWuhKXlJMQh5SQ1xLjPnjyTD2PXXCK3V2DlZazMv3otjUkUQT2WQ2mqFdLlN8r73mifop3Cme2H-j7DVx_VUTyCZSeO_nLCqM-SXktUA8crEH5KYF-5mCqN-5i16QGiXq9NuaOAU1phY5dt6Uk"
        }
        """
    
    static let twoFactorResponse = """
        {
            "result": "requires-two-factor",
            "schemes": {
                "email": {
                    "configured": true,
                    "trigger_route": "http://yourparkingspace.localhost:8080/api/v2/auth/two_factor_trigger?user_id=886298&nonce=qNH9UcPcrYVnXWJjP90%2FM%2B1c%2FXHgrJBLXVy27JDPZJs%3D&scheme=email",
                    "destination": "******iller@yourparkingspace.co.uk"
                },
                "sms": {
                    "configured": false,
                    "trigger_route": null,
                    "destination": null
                }
            }
        }
        """
}
