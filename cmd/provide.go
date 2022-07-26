package cmd

import (
	"github.com/fox-one/mixin-sdk-go"
	"github.com/fox-one/pkg/store/db"
	"github.com/pandodao/dirtoracle-mvm/core"
	"github.com/pandodao/dirtoracle-mvm/service/wallet"
	"github.com/pandodao/dirtoracle-mvm/store/asset"
)

func provideSystem() *core.System {
	return &core.System{
		Signers:         cfg.Oracle.Signers,
		SignerThreshold: cfg.Oracle.Threshold,
		ClientID:        cfg.Dapp.ClientID,
		MvmGroups:       cfg.MVM.Groups,
		MvmThreshold:    cfg.MVM.Threshold,
		MvmProcess:      cfg.MVM.Process,

		GasAsset:  cfg.Gas.Asset.String(),
		GasAmount: cfg.Gas.Amount,
	}
}

func provideMixinClient() *mixin.Client {
	c, err := mixin.NewFromKeystore(&cfg.Dapp.Keystore)
	if err != nil {
		panic(err)
	}

	return c
}

func provideWalletService(client *mixin.Client) core.WalletService {
	return wallet.New(client, wallet.Config{
		Pin: cfg.Dapp.Pin,
	})
}

func provideDatabase() *db.DB {
	database, err := db.Open(cfg.DB)
	if err != nil {
		panic(err)
	}

	if err := db.Migrate(database); err != nil {
		panic(err)
	}

	return database
}

func provideAssetStore(db *db.DB) core.AssetStore {
	return asset.New(db)
}
