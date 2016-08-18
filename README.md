[TOC]

# Info

This is fast-encrypt-decode for golang uitls

# Use

install

```sh
go get -u -v github.com/sinlov/fastEncryptDecode
```

## import

```golang
import (
    "github.com/sinlov/fastEncryptDecode"
)
```


## MD5


- MD5Hash

```golang
    str4MD5 := "0987654321"
	enMD5 := MD5hash([]byte(str4MD5))
	// if string
	enMD5 := String2MD5(str4MD5)
```


- MD5 Verify

```golang
    verifyTrue := MD5Verify(str4MD5, "25d55ad283aa400af464c761d713c07a")
```

## AES CBC PKCS7

this package use `CBC pkcs7 padding` length `128byte` or string size `16`

- string

```golang
    str4AES := "qwertasdgzxcv"
    enAES, err := fastEncryptDecode.AES_CBC_PKCS7_Encrypt(str4AES, AES_KEY)
    deASE, err := fastEncryptDecode.AES_CBC_PKCS7_Decrypt(enAES, AES_KEY)
```


- []byte

```golang
    str4AES := "qwer1234aisudfhsfhsidhaskfahfahkufahukfh"
    enAES, err := fastEncryptDecode.AES_CBC_PKCS7_EncryptByte([]byte(str4AES), []byte(AES_KEY))
    deAES, err := fastEncryptDecode.AES_CBC_PKCS7_DecryptByte(enAES, []byte(AES_KEY))
```


## AES ECB PKCS5

this package use `ECB pkcs5 padding` length `128byte` or string size `16`

- string

```golang
    str4AES := "qwer1234adasdadadasdadaasadashkafhkfhkf"
	enAES, err := AES_ECB_PKCS5_Encrypt(str4AES, AES_KEY)
	deASE, err := AES_ECB_PKCS5_Decrypt(enAES, AES_KEY)
```

- []byte

```golang
    str4AES := "qwer1234aisudfhsfhsidhaskfahfahkufahukfhkadadasdadadasdadaasadashkafhkfhkf"
	enAES, err := AES_ECB_PKCS5_EncryptByte([]byte(str4AES), []byte(AES_KEY))
	deAES, err := AES_ECB_PKCS5_DecryptByte(enAES, []byte(AES_KEY))
```

## Base64UrlSafeEncode

for encode by `AES_CBC_PKCS7_Encrypt` or `AES_ECB_PKCS5_Encrypt` result

```golang
fmt.Println("base64UrlSafe: ", Base64UrlSafeEncode(enAES))
```

#License

---

Copyright 2016 sinlovgm@gmail.com

Licensed under the Apache License, Version 2.0 (the "License");
you may not use this file except in compliance with the License.
You may obtain a copy of the License at

   http://www.apache.org/licenses/LICENSE-2.0

Unless required by applicable law or agreed to in writing, software
distributed under the License is distributed on an "AS IS" BASIS,
WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
See the License for the specific language governing permissions and
limitations under the License.