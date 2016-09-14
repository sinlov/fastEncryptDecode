package fastEncryptDecode

import (
	"testing"
	"github.com/bmizerany/assert"
	"fmt"
	"encoding/binary"
	"unsafe"
)

const AES_KEY string = "qwerty1234567890"

func TestByteArr2HexStr(t *testing.T) {
	fmt.Println("\nTestByteArr2HexStr")
	str4Hex := "12345qwert"
	fmt.Println("str4Hex", str4Hex)
	hexStr := []byte(str4Hex)
	fmt.Println("hexStr", hexStr)
	hexString := ByteArr2HexStr(hexStr)
	fmt.Println("ByteArr2HexString", hexString)
	assert.Equal(t, nil, nil)
}

func TestByteArr2HexStrArr(t *testing.T) {
	fmt.Println("\nTestByteArr2HexStrArr")
	str4Hex := "12345qwert"
	fmt.Println("str4Hex", str4Hex)
	hexStr := []byte(str4Hex)
	fmt.Println("hexStr", hexStr)
	hexStrArr := ByteArr2HexStrArr(hexStr)
	for _, s := range hexStrArr {
		fmt.Println("ByteArr2HexStrArr: ", s)
	}
	assert.Equal(t, nil, nil)
}

func TestHexStr2ByteArr(t *testing.T) {
	fmt.Println("\nTestHexStr2ByteArr")
	str4Hex := "12345qwert"
	fmt.Println("str4Hex", str4Hex)
	hexStr := []byte(str4Hex)
	fmt.Println("hexStr", hexStr)
	hexString := ByteArr2HexStr(hexStr)
	fmt.Println("ByteArr2HexStr", hexString)
	byteArr, err := HexStr2ByteArr(hexString)
	fmt.Println("byteArr", byteArr)
	assert.Equal(t, hexStr, byteArr, err)
}

func TestByteAndUint(t *testing.T) {
	fmt.Println("\nTestByteAndUint")
	// byte to uint8
	b := 0x13
	i := uint8(b)
	fmt.Println("byte: ", b, " uint8: ", i)
	// uint8 to byte
	var i4T uint8
	i4T = 3
	b4T := byte(i4T)
	fmt.Println("uint8: ", i4T, " byte: ", b4T)
	// byte[] to uint 16 32 64 use | package encoding/binary
	dataUint16 := []byte{0x12, 0x24}
	fmt.Println("dataUint16: ", len(dataUint16))
	uUint16 := binary.BigEndian.Uint16(dataUint16)
	fmt.Println("uUint16:", unsafe.Sizeof(uUint16))
	fmt.Println("byte arrar: ", dataUint16, " Uint16: ", uUint16)
	dataUint32 := []byte{0x12, 0x24, 0x36, 0x48}
	fmt.Println("dataUint32: ", len(dataUint32))
	uUint32 := binary.BigEndian.Uint32(dataUint32)
	fmt.Println("uUint32: ", unsafe.Sizeof(uUint32))
	fmt.Println("byte arrar: ", dataUint32, " Uint32: ", uUint32)
	dataUint64 := []byte{0x12, 0x24, 0x36, 0x48, 0x51, 0x62, 0x73, 0x74}
	fmt.Println("dataUint64: ", len(dataUint64))
	uUint64 := binary.BigEndian.Uint64(dataUint64)
	fmt.Println("uUint64: ", unsafe.Sizeof(uUint64))
	fmt.Println("byte arrar: ", dataUint64, " uUint64: ", uUint64)
	assert.Equal(t, nil, nil)
}

func TestUtf82Unicode(t *testing.T) {
	fmt.Println("\n" + "TestUtf82Unicode")
	bStr := "转换前的中文"
	enUnicode := Utf82Unicode(bStr)
	fmt.Println(bStr, enUnicode)
	assert.Equal(t, nil, nil)
}

func TestUnicode2Utf8(t *testing.T) {
	fmt.Println("\n" + "TestUtf82Unicode")
	bStr := "转换前的中文"
	enUnicode := Utf82Unicode(bStr)
	enUtf8 := Unicode2Utf8(enUnicode)
	fmt.Println(bStr, enUnicode, enUtf8)
	assert.Equal(t, bStr, enUtf8, nil)
}

func TestMD5hash(t *testing.T) {
	fmt.Println("\n" + "TestMD5hash")
	str4MD5 := "0987654321"
	enMD5 := MD5hash([]byte(str4MD5))
	fmt.Println(str4MD5, enMD5)
	assert.Equal(t, nil, nil)
}

func TestString2MD5(t *testing.T) {
	fmt.Println("\n" + "TestString2MD5")
	str4MD5 := "12345678"
	enMD5 := String2MD5(str4MD5)
	fmt.Println(str4MD5, enMD5)
	assert.Equal(t, nil, nil)
}

func TestMD5Verify(t *testing.T) {
	fmt.Println("\n" + "TestMD5Verify")
	str4MD5 := "12345678"
	enMD5 := String2MD5(str4MD5)
	verifyTrue := MD5Verify(str4MD5, enMD5)
	fmt.Println(str4MD5, enMD5, verifyTrue)
	verifyFalse := MD5Verify(str4MD5, "25d55ad283aa400af464c76d713c07a")
	fmt.Println(str4MD5, "25d55ad283aa400af464c76d713c07a", verifyFalse)
	tBool := verifyTrue && !verifyFalse
	assert.T(t, tBool, nil)
}

func TestAES_CBC_PKCS7_EncryptByte(t *testing.T) {
	fmt.Println("\n" + "TestAES_CBC_PKCS7_EncryptByte")
	str4AES := "qwer1234aisudfhsfhsidhaskfahfahkufahukfhkashkafhkfhkf"
	enAES, err := AES_CBC_PKCS7_EncryptByte([]byte(str4AES), []byte(AES_KEY))
	fmt.Println(str4AES, enAES)
	fmt.Println("base64UrlSafe: ", Base64UrlSafeEncode(enAES))
	assert.Equal(t, nil, err)
}

func TestAES_CBC_PKCS7_DecryptByte(t *testing.T) {
	fmt.Println("\n" + "TestAES_CBC_PKCS7_DecryptByte")
	str4AES := "qwer1234aisudfhsfhsidhaskfahfahkufahukfhkadadasdadadasdadaasadashkafhkfhkf"
	enAES, err := AES_CBC_PKCS7_EncryptByte([]byte(str4AES), []byte(AES_KEY))
	fmt.Println(str4AES)
	fmt.Println(ByteArr2Str(enAES))
	fmt.Println("base64UrlSafe: ", Base64UrlSafeEncode(enAES))
	deAES, err := AES_CBC_PKCS7_DecryptByte(enAES, []byte(AES_KEY))
	pStr := ByteArr2Str(deAES)
	fmt.Println(pStr)
	assert.Equal(t, str4AES, pStr, err)
}

func TestAES_CBC_PKCS7_Encrypt(t *testing.T) {
	fmt.Println("\n" + "TestAES_CBC_PKCS7_Encrypt")
	str4AES := "qwer1234adasdadadasdadaasadashkafhkfhkf"
	enAES, err := AES_CBC_PKCS7_Encrypt(str4AES, AES_KEY)
	fmt.Println(str4AES)
	fmt.Println(enAES)
	fmt.Println("base64UrlSafe: ", Base64UrlSafeEncode([]byte(enAES)))
	assert.Equal(t, nil, err)
}

func TestAES_CBC_PKCS7_Decrypt(t *testing.T) {
	fmt.Println("\n" + "TestAES_CBC_PKCS7_Decrypt")
	str4AES := "qwertasdgzxcv"
	enAES, err := AES_CBC_PKCS7_Encrypt(str4AES, AES_KEY)
	deASE, err := AES_CBC_PKCS7_Decrypt(enAES, AES_KEY)
	fmt.Println(str4AES)
	fmt.Println(enAES)
	fmt.Println("base64UrlSafe: ", Base64UrlSafeEncode([]byte(enAES)))
	fmt.Println(deASE)
	assert.Equal(t, str4AES, deASE, err)
}

func TestAES_ECB_PKCS5_Encrypt(t *testing.T) {
	fmt.Println("\n" + "TestAES_ECB_PKCS5_Encrypt")
	str4AES := "qwer1234adasdadadasdadaasadashkafhkfhkf"
	enAES, err := AES_ECB_PKCS5_Encrypt(str4AES, AES_KEY)
	fmt.Println(str4AES)
	fmt.Println(enAES)
	fmt.Println("base64UrlSafe: ", Base64UrlSafeEncode([]byte(enAES)))
	assert.Equal(t, nil, err)
}

func TestAES_ECB_PKCS5_Decrypt(t *testing.T) {
	fmt.Println("\n" + "TestAES_ECB_PKCS5_Decrypt")
	str4AES := "qwer1234adasdadadasdadaasadashkafhkfhkf"
	enAES, err := AES_ECB_PKCS5_Encrypt(str4AES, AES_KEY)
	deASE, err := AES_ECB_PKCS5_Decrypt(enAES, AES_KEY)
	fmt.Println(str4AES)
	fmt.Println(enAES)
	fmt.Println("base64UrlSafe: ", Base64UrlSafeEncode([]byte(enAES)))
	fmt.Println(deASE)
	assert.Equal(t, str4AES, deASE, err)
}

func TestAES_ECB_PKCS5_EncryptByte(t *testing.T) {
	fmt.Println("\n" + "TestAES_ECB_PKCS5_EncryptByte")
	str4AES := "{\"data\":null,\"msg\":\"提交的数据为空!\",\"status\":0}"
	enAES, err := AES_ECB_PKCS5_EncryptByte([]byte(str4AES), []byte("gf*#&1&(g*UjX!h*"))
	fmt.Println(str4AES)
	fmt.Println(ByteArr2Str(enAES))
	fmt.Println("base64UrlSafe: ", ByteArr2HexStr(enAES))
	assert.Equal(t, nil, err)
}

func TestAES_ECB_PKCS5_DecryptByte(t *testing.T) {
	fmt.Println("\n" + "TestAES_ECB_PKCS5_DecryptByte")
	str4AES := "qwer1234aisudfhsfhsidhaskfahfahkufahukfhkadadasdadadasdadaasadashkafhkfhkf"
	enAES, err := AES_ECB_PKCS5_EncryptByte([]byte(str4AES), []byte(AES_KEY))
	fmt.Println(str4AES)
	fmt.Println(ByteArr2Str(enAES))
	fmt.Println("base64UrlSafe: ", Base64UrlSafeEncode(enAES))
	deAES, err := AES_ECB_PKCS5_DecryptByte(enAES, []byte(AES_KEY))
	pStr := ByteArr2Str(deAES)
	fmt.Println(pStr)
	assert.Equal(t, str4AES, pStr, err)
}