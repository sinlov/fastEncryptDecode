package fastEncryptDecode

import (
	"testing"
	"github.com/bmizerany/assert"
	"fmt"
)

const AES_KEY string = "qwerty1234567890"

func TestString2MD5(t *testing.T) {
	str4MD5 := "12345678"
	enMD5 := String2MD5(str4MD5)
	fmt.Println(enMD5)
	assert.Equal(t, nil, nil)
}

func TestMD5hash(t *testing.T) {
	str4MD5 := "0987654321"
	enMD5 := MD5hash(str4MD5)
	fmt.Println(enMD5)
	assert.Equal(t, nil, nil)
}

func TestMD5Verify(t *testing.T) {
	str4MD5 := "12345678"
	enMD5 := String2MD5(str4MD5)
	fmt.Println(enMD5)
	fmt.Println(MD5Verify(str4MD5, enMD5))
	fmt.Println(MD5Verify(str4MD5, "25d55ad283aa400af464c76d713c07a"))
	assert.Equal(t, nil, nil)
}

func TestAES_CBC_PKCS7_EncryptByte(t *testing.T) {
	str4AES := "qwer1234aisudfhsfhsidhaskfahfahkufahukfhkashkafhkfhkf"
	enAES, err := AES_CBC_PKCS7_EncryptByte([]byte(str4AES), []byte(AES_KEY))
	fmt.Println(enAES)
	assert.Equal(t, nil, err)
}

func TestAES_CBC_PKCS7_DecryptByte(t *testing.T) {
	str4AES := "qwer1234aisudfhsfhsidhaskfahfahkufahukfhkadadasdadadasdadaasadashkafhkfhkf"
	enAES, err := AES_CBC_PKCS7_EncryptByte([]byte(str4AES), []byte(AES_KEY))
	fmt.Println(byteString(enAES))
	deAES, err := AES_CBC_PKCS7_DecryptByte(enAES, []byte(AES_KEY))
	fmt.Println(byteString(deAES))
	assert.Equal(t, nil, err)
}

func byteString(p []byte) string {
	for i := 0; i < len(p); i++ {
		if p[i] == 0 {
			return string(p[0:i])
		}
	}
	return string(p)
}

func TestAES_CBC_PKCS7_Encrypt(t *testing.T) {
	str4AES := "qwer1234adasdadadasdadaasadashkafhkfhkf"
	enAES, err := AES_CBC_PKCS7_Encrypt(str4AES, AES_KEY)
	fmt.Println(enAES)
	assert.Equal(t, nil, err)
}

func TestAES_CBC_PKCS7_Decrypt(t *testing.T) {
	str4AES := "qwertasdgzxcv"
	enAES, err := AES_CBC_PKCS7_Encrypt(str4AES, AES_KEY)
	deASE, err := AES_CBC_PKCS7_Decrypt(enAES, AES_KEY)
	fmt.Println(enAES)
	fmt.Println(deASE)
	assert.Equal(t, nil, err)
}

func TestAES_ECB_PKCS5_Encrypt(t *testing.T) {
	str4AES := "qwer1234adasdadadasdadaasadashkafhkfhkf"
	enAES, err := AES_ECB_PKCS5_Encrypt(str4AES, AES_KEY)
	fmt.Println(enAES)
	fmt.Println("base64UrlSafe result:", Base64UrlSafeEncode([]byte(enAES)))
	assert.Equal(t, nil, err)
}

func TestAES_ECB_PKCS5_Decrypt(t *testing.T) {
	str4AES := "qwer1234adasdadadasdadaasadashkafhkfhkf"
	enAES, err := AES_ECB_PKCS5_Encrypt(str4AES, AES_KEY)
	deASE, err := AES_ECB_PKCS5_Decrypt(enAES, AES_KEY)
	fmt.Println(enAES)
	fmt.Println(deASE)
	assert.Equal(t, nil, err)
}
