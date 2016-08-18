package fastEncryptDecode

import (
	"crypto/md5"
	"encoding/hex"
	"crypto/aes"
	"crypto/cipher"
	"bytes"
	"strings"
	"encoding/base64"
)

type ecbEncrypter ecb

type ecb struct {
	b         cipher.Block
	blockSize int
}

func newECB(b cipher.Block) *ecb {
	return &ecb{
		b:         b,
		blockSize: b.BlockSize(),
	}
}

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

func MD5Verify(code string, md5Str string) bool {
	return 0 == strings.Compare(String2MD5(code), md5Str)
}

//MD5 hash
func MD5hash(str string) string {
	return String2MD5(str)
}

// AES encrypt pkcs7padding CBC, key for choose algorithm
func AES_CBC_PKCS7_Encrypt(plantText, key string) (string, error) {
	res, err := AES_CBC_PKCS7_EncryptByte([]byte(plantText), []byte(key))
	return byte2String(res), err
}


// AES encrypt pkcs7padding CBC, key for choose algorithm
func AES_CBC_PKCS7_EncryptByte(plantText, key []byte) ([]byte, error) {
	block, err := aes.NewCipher(key)
	if err != nil {
		return nil, err
	}
	plantText = pKCS7Padding(plantText, block.BlockSize())

	blockModel := cipher.NewCBCEncrypter(block, key)

	cipherText := make([]byte, len(plantText))

	blockModel.CryptBlocks(cipherText, plantText)
	return cipherText, nil
}

func AES_CBC_PKCS7_Decrypt(cipherText, key string) (string, error) {
	result, err := AES_CBC_PKCS7_DecryptByte([]byte(cipherText), []byte(key))
	str := byte2String(result)
	return str, err
}

func AES_CBC_PKCS7_DecryptByte(cipherText, key []byte) ([]byte, error) {
	keyBytes := []byte(key)
	block, err := aes.NewCipher(keyBytes)
	if err != nil {
		return nil, err
	}
	blockModel := cipher.NewCBCDecrypter(block, keyBytes)
	plantText := make([]byte, len(cipherText))
	blockModel.CryptBlocks(plantText, cipherText)
	plantText = pKCS7UnPadding(plantText, block.BlockSize())
	return plantText, nil
}

//AES Decrypt pkcs7padding CBC, key for choose algorithm
func pKCS7UnPadding(plantText []byte, blockSize int) []byte {
	length := len(plantText)
	unPadding := int(plantText[length - 1])
	return plantText[:(length - unPadding)]
}

func pKCS7Padding(cipherText []byte, blockSize int) []byte {
	padding := blockSize - len(cipherText) % blockSize
	padText := bytes.Repeat([]byte{byte(padding)}, padding)
	return append(cipherText, padText...)
}

func AES_ECB_PKCS5_Encrypt(cipherText, key string) (string, error) {
	result, err := AES_ECB_PKCS5_EncryptByte([]byte(cipherText), []byte(key))
	str := byte2String(result)
	return str, err
}

func AES_ECB_PKCS5_EncryptByte(cipherText, key []byte) ([]byte, error) {
	keyBytes := []byte(key)
	block, err := aes.NewCipher(keyBytes)
	if err != nil {
		return nil, err
	}
	ecb := newECBEncrypter(block)
	content := cipherText
	content = PKCS5Padding(content, block.BlockSize())
	crypted := make([]byte, len(content))
	ecb.CryptBlocks(crypted, content)
	// 普通base64编码加密 区别于urlsafe base64
	return crypted, nil
}

func AES_ECB_PKCS5_Decrypt(cipherText, key string) (string, error) {
	result, err := AES_ECB_PKCS5_DecryptByte([]byte(cipherText), []byte(key))
	str := byte2String(result)
	return str, err
}

func AES_ECB_PKCS5_DecryptByte(cipherText, key []byte) ([]byte, error) {
	keyBytes := []byte(key)
	block, err := aes.NewCipher(keyBytes)
	if err != nil {
		return nil, err
	}
	blockMode := newECBDecrypter(block)
	origData := make([]byte, len(cipherText))
	blockMode.CryptBlocks(origData, cipherText)
	origData = PKCS5UnPadding(origData)
	return origData, nil
}

func Base64UrlSafeEncode(source []byte) string {
	// Base64 Url Safe is the same as Base64 but does not contain '/' and '+' (replaced by '_' and '-') and trailing '=' are removed.
	bytearr := base64.StdEncoding.EncodeToString(source)
	safeurl := strings.Replace(string(bytearr), "/", "_", -1)
	safeurl = strings.Replace(safeurl, "+", "-", -1)
	safeurl = strings.Replace(safeurl, "=", "", -1)
	return safeurl
}

func PKCS5Padding(cipherText []byte, blockSize int) []byte {
	padding := blockSize - len(cipherText) % blockSize
	padText := bytes.Repeat([]byte{byte(padding)}, padding)
	return append(cipherText, padText...)
}

func PKCS5UnPadding(origData []byte) []byte {
	length := len(origData)
	// 去掉最后一个字节 unpadding 次
	unpadding := int(origData[length - 1])
	return origData[:(length - unpadding)]
}

// NewECBEncrypter returns a BlockMode which encrypts in electronic code book
// mode, using the given Block.
func newECBEncrypter(b cipher.Block) cipher.BlockMode {
	return (*ecbEncrypter)(newECB(b))
}
func (x *ecbEncrypter) BlockSize() int {
	return x.blockSize
}
func (x *ecbEncrypter) CryptBlocks(dst, src []byte) {
	if len(src) % x.blockSize != 0 {
		panic("crypto/cipher: input not full blocks")
	}
	if len(dst) < len(src) {
		panic("crypto/cipher: output smaller than input")
	}
	for len(src) > 0 {
		x.b.Encrypt(dst, src[:x.blockSize])
		src = src[x.blockSize:]
		dst = dst[x.blockSize:]
	}
}

type ecbDecrypter ecb

// NewECBDecrypter returns a BlockMode which decrypts in electronic code book
// mode, using the given Block.
func newECBDecrypter(b cipher.Block) cipher.BlockMode {
	return (*ecbDecrypter)(newECB(b))
}
func (x *ecbDecrypter) BlockSize() int {
	return x.blockSize
}
func (x *ecbDecrypter) CryptBlocks(dst, src []byte) {
	if len(src) % x.blockSize != 0 {
		panic("crypto/cipher: input not full blocks")
	}
	if len(dst) < len(src) {
		panic("crypto/cipher: output smaller than input")
	}
	for len(src) > 0 {
		x.b.Decrypt(dst, src[:x.blockSize])
		src = src[x.blockSize:]
		dst = dst[x.blockSize:]
	}
}