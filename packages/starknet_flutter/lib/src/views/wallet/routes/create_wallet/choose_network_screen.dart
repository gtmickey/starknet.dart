import 'package:flutter/material.dart';
import 'package:starknet_flutter/src/views/wallet/wallet_initialization_presenter.dart';
import 'package:starknet_flutter/src/views/wallet/wallet_initialization_viewmodel.dart';
import 'package:starknet_flutter/src/views/widgets/starknet_button.dart';

import '../../../../models/wallet.dart';

class ChooseNetworkScreen extends StatelessWidget {
  static const routeName = '/choose_network';

  final WalletInitializationPresenter presenter;
  final WalletInitializationViewModel model;

  const ChooseNetworkScreen({
    super.key,
    required this.presenter,
    required this.model,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Text("Choose your network"),
            const SizedBox(height: 32),
            StarknetButton.plain(
              onTap: () {
                model.networkType = StarknetNetworkType.goerli;
                // TODO Create a real wallet
                presenter.createWallet(
                  Wallet(
                    name: "Wallet 1",
                    order: 0,
                    accountType: model.accountType!,
                  ),
                );
              },
              text: 'StarkNet Goerli Alpha',
            ),
            const SizedBox(height: 16),
            StarknetButton.plain(
              onTap: () {
                model.networkType =
                    StarknetNetworkType.mainnet; // TODO Create a real wallet
                presenter.createWallet(
                  Wallet(
                    name: "Wallet 1",
                    order: 0,
                    accountType: model.accountType!,
                  ),
                );
              },
              text: 'StarkNet Mainnet Alpha',
            ),
          ],
        ),
      ),
    );
  }
}
