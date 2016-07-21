package fastEncryptDecode

import (
	"crypto/md5"
	"encoding/hex"
	"crypto/aes"
	"crypto/cipher"
	"bytes"
	"strings"
)

// byte array to string
func byte2String(p []byte) string {
	for i := 0; i < len(p); i++ {
		if p[i] == 0 {
			return string(p[0:i])
		}
	}
	return string(p)
}

//string to md5
func String2MD5(code string) string {
	h := md5.New()
	h.Write([]byte(code))
	rs := hex.EncodeToString(h.Sum(nil))
	return rs
}

func MD5Verify(code string, md5Str string) bool{
	return 0 == strings.Compare(String2MD5(code), md5Str)
}

//MD5 hash
func MD5hash(str string) string{
	return String2MD5(str)
}

// AES encrypt pkcs7padding CBC, key for choose algorithm
func AESPKCS7Encrypt(plantText, key string) (string, error) {
	res, err := AESPKCS7EncryptByte([]byte(plantText), []byte(key))
	return byte2String(res), err
}


// AES encrypt pkcs7padding CBC, key for choose algorithm
func AESPKCS7EncryptByte(plantText, key []byte) ([]byte, error) {
	block, err := aes.NewCipher(key)
	if err != nil {
		return nil, err
	}
	plantText = PKCS7Padding(plantText, block.BlockSize())

	blockModel := cipher.NewCBCEncrypter(block, key)

	cipherText := make([]byte, len(plantText))

	blockModel.CryptBlocks(cipherText, plantText)
	return cipherText, nil
}

func PKCS7Padding(cipherText []byte, blockSize int) []byte {
	padding := blockSize - len(cipherText) % blockSize
	padtext := bytes.Repeat([]byte{byte(padding)}, padding)
	return append(cipherText, padtext...)
}

func AESPKCS7Decrypt(cipherText, key string) (string, error) {
	result, err := AESPKCS7DecryptByte([]byte(cipherText), []byte(key))
	str := byte2String(result)
	return str ,err
}

//AES Decrypt pkcs7padding CBC, key for choose algorithm
func AESPKCS7DecryptByte(cipherText, key []byte) ([]byte, error) {
	keyBytes := []byte(key)
	block, err := aes.NewCipher(keyBytes)
	if err != nil {
		return nil, err
	}
	blockModel := cipher.NewCBCDecrypter(block, keyBytes)
	plantText := make([]byte, len(cipherText))
	blockModel.CryptBlocks(plantText, cipherText)
	plantText = PKCS7UnPadding(plantText, block.BlockSize())
	return plantText, nil
}

func PKCS7UnPadding(plantText []byte, blockSize int) []byte {
	length := len(plantText)
	unPadding := int(plantText[length - 1])
	return plantText[:(length - unPadding)]
}