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

```golang
    str4MD5 := "12345678"
    enMD5:= fastEncryptDecode.String2MD5(str4MD5)
    // or
    str4MD51 := "0987654321"
    enMD5:= fastEncryptDecode.MD5hash(str4MD51)
```

- MD5 Verify

```golang
    MD5Verify(str4MD5, "25d55ad283aa400af464c761d713c07a")
```

## AES 

this package use `pkcs7padding CBC` length `128byte` or string size `16`

- string

```golang
    str4AES := "qwertasdgzxcv"
    enAES, err := fastEncryptDecode.AESPKCS7Encrypt(str4AES, AES_KEY)
    deASE, err := fastEncryptDecode.AESPKCS7Decrypt(enAES, AES_KEY)
    fmt.Println(enAES)
    fmt.Println(deASE)
```

- []byte

```golang
    str4AES := "qwer1234aisudfhsfhsidhaskfahfahkufahukfh"
    enAES, err := fastEncryptDecode.AESPKCS7EncryptByte([]byte(str4AES), []byte(AES_KEY))
    deAES, err := fastEncryptDecode.AESPKCS7DecryptByte(enAES, []byte(AES_KEY))
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