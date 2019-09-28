package main

import "C"

import (
	"fmt"
	"os"

	"github.com/rubblelabs/ripple/crypto"
	"github.com/rubblelabs/ripple/data"
)

func checkerr(err error) {
	if err != nil {
		fmt.Println(err.Error())
		os.Exit(1)
	}
}

//export Payment
func Payment(acct, dest, amt, s *C.char, seq C.uint) *C.char {
	keyseq := uint32(0)
	seed, err := crypto.NewRippleHashCheck(C.GoString(s), crypto.RIPPLE_FAMILY_SEED)
	checkerr(err)
	key, err := crypto.NewECDSAKey(seed.Payload())
	checkerr(err)
	account, err := data.NewAccountFromAddress(C.GoString(acct))
	checkerr(err)
	destination, err := data.NewAccountFromAddress(C.GoString(dest))
	checkerr(err)
	amount, err := data.NewAmount(C.GoString(amt))
	checkerr(err)
	payment := &data.Payment{
		Destination: *destination,
		Amount:      *amount,
	}
	payment.Account = *account
	minfee, _ := data.NewNativeValue(int64(120))
	payment.Fee = *minfee
	payment.TransactionType = data.PAYMENT
	payment.Flags = new(data.TransactionFlag)
	*payment.Flags = *payment.Flags | data.TxCanonicalSignature
	payment.Sequence = uint32(seq)
	err = data.Sign(payment, key, &keyseq)
	checkerr(err)
	_, raw, err := data.Raw(payment)
	checkerr(err)
	return C.CString(fmt.Sprintf("%X", raw))
}

func main() {}
