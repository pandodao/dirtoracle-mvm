/*
Copyright © 2021 NAME HERE <EMAIL ADDRESS>

Licensed under the Apache License, Version 2.0 (the "License");
you may not use this file except in compliance with the License.
You may obtain a copy of the License at

	http://www.apache.org/licenses/LICENSE-2.0

Unless required by applicable law or agreed to in writing, software
distributed under the License is distributed on an "AS IS" BASIS,
WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
See the License for the specific language governing permissions and
limitations under the License.
*/
package cmd

import (
	"fmt"

	"github.com/pandodao/blst/en256"
	"github.com/pandodao/dirtoracle-mvm/core"
	"github.com/spf13/cobra"
)

// exportPubkeysCmd represents the export public keys command
var exportPubkeysCmd = &cobra.Command{
	Use:     "export-pubkeys",
	Aliases: []string{"ep"},
	Short:   "export public keys",
	Run: func(cmd *cobra.Command, args []string) {
		system := provideSystem()
		allPubkeys := searchPublicKeys(system.Signers, int(system.SignerThreshold))
		for _, signers := range allPubkeys {
			var (
				mask      int64
				enPubkeys []*en256.PublicKey
				indexs    []int64
			)
			for _, signer := range signers {
				indexs = append(indexs, int64(signer.Index))
				mask = mask | (0x1 << signer.Index)
				enPubkeys = append(enPubkeys, signer.En256VerifyKey)
			}

			pubkey := en256.AggregatePublicKeys(enPubkeys).String()
			fmt.Println(
				"indexs", indexs,
				"mask", mask,
				"en256_public_key", pubkey,
				"0x"+pubkey[64:128],
				"0x"+pubkey[:64],
				"0x"+pubkey[192:],
				"0x"+pubkey[128:192],
			)
		}
	},
}

func searchPublicKeys(signers []*core.Signer, threshold int) [][]*core.Signer {
	if threshold == 0 || len(signers) < threshold {
		return [][]*core.Signer{}
	} else if len(signers) == threshold {
		return [][]*core.Signer{signers}
	}
	result := searchPublicKeys(signers[1:], threshold-1)
	for i := range result {
		result[i] = append([]*core.Signer{signers[0]}, result[i]...)
	}
	if threshold == 1 {
		result = append(result, []*core.Signer{signers[0]})
	}
	result = append(result, searchPublicKeys(signers[1:], threshold)...)
	return result
}

func init() {
	rootCmd.AddCommand(exportPubkeysCmd)
}
