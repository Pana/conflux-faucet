<template>
  <div>
    <el-row type="flex" justify="center">
      <el-col :span="20">
        <el-card shadow="hover">
          <el-row>
            <el-col :span="7">{{ $t("message.selectToken") }}</el-col>
            <el-col :span="11">
              <el-select
                v-model="selectedToken"
                filterable
                :placeholder="$t('message.selectText')"
                @change="changeToken"
                size="mini"
                class="full-width"
                :disabled="!isFreeState"
              >
                <el-option
                  v-for="item in options"
                  :key="item.value"
                  :label="item.label"
                  :value="item.value"
                  :disabled="item.disabled"
                >
                </el-option>
              </el-select>
            </el-col>
            <el-col :offset="1" :span="3">
              <el-tooltip
                class="item"
                effect="dark"
                :content="queryingBalance"
                placement="bottom-start"
                :disabled="!isButtonDisabled"
              >
                <div>
                  <el-button type="primary" size="mini" :disabled="isButtonDisabled" @click="claim">
                    {{ $t("message.claim") }}
                  </el-button>
                </div>
              </el-tooltip>
            </el-col>
          </el-row>

          <el-row type="flex" v-if="isDev">
            <el-col :span="7">代币余额</el-col>
            <el-col :span="10">
              <div class="full-width">
                {{ queryingBalance }}
              </div>
            </el-col>
            <el-col :span="1">
              <el-tooltip
                v-if="isNativeToken ? cfxBalance : tokenBalance"
                class="item"
                effect="dark"
                :content="isNativeToken ? cfxBalance : tokenBalance"
                placement="right"
              >
                <div class="right-align bold-font">
                  <label class="main-background"> ... </label>
                </div>
              </el-tooltip>
            </el-col>
          </el-row>
          <el-divider v-if="isDev"></el-divider>
          <el-row type="flex" v-if="isDev">
            <el-col :span="7">
              代币池余额
              <el-tooltip effect="light" content="代币池余额并非实时更新，用户操作后会进行更新">
                <i class="header-icon el-icon-info"></i>
              </el-tooltip>
            </el-col>
            <el-col :span="10">
              <div class="full-width">
                {{ queryingFaucetBalance }}
              </div>
            </el-col>
            <el-col :span="1">
              <el-tooltip
                v-if="isNativeToken ? faucetCfxBalance : faucetTokenBalance"
                class="item"
                effect="dark"
                :content="isNativeToken ? faucetCfxBalance : faucetTokenBalance"
                placement="right"
              >
                <div class="right-align bold-font">
                  <label class="main-background"> ... </label>
                </div>
              </el-tooltip>
            </el-col>
            <el-col :offset="1" :span="2">
              <el-input
                v-model="depositAmount"
                oninput="value=value.replace(/[^\d]/g,'')"
                size="mini"
                :placeholder="defaultDepositAmount"
              >
              </el-input>
            </el-col>
            <el-col :span="1" v-if="isDev">
              <el-button type="warning" size="mini" :disabled="!isFreeState" @click="deposit">
                deposit
              </el-button>
            </el-col>
          </el-row>
        </el-card>
      </el-col>
    </el-row>

    <el-row type="flex" justify="center" v-if="!isFreeState || latestTransactionInfo.selectedToken">
      <el-col :span="20">
        <current-transaction-panel
          v-bind:latestTransactionInfo="latestTransactionInfo"
          v-bind:tagTheme="tagTheme"
          v-bind:stateType="stateType"
          v-bind:txState="txState"
          v-on:show-tx-state="showTxState"
        ></current-transaction-panel>
      </el-col>
    </el-row>
    <el-row type="flex" justify="center">
      <el-col :span="20">
        <info-panel
          :faucetAmount="faucetAmount"
          :faucetInterval="faucetInterval"
        ></info-panel>
      </el-col>
    </el-row>
    <!-- <el-row type="flex" justify="center" v-if="isDev">
      <el-col :span="20">
        <history-transaction-panel
          v-bind:transactionList="transactionList"
          v-on:reset-transaction-list="resetTransactionList"
        ></history-transaction-panel>
      </el-col>
    </el-row> -->
    <el-dialog :visible.sync="executedDialogVisible" :title="$t('message.successClaim')" width="50%" :show-close="false">
      <el-row>
        <span>
          {{$t('message.transactionHash')}}
          <el-tooltip effect="light" :content="$t('message.tooltip.successClaim')">
            <i class="header-icon el-icon-info"></i>
          </el-tooltip>：
          <el-link :href="scanTransacationUrl" type="primary" target="_blank">{{latestTransactionInfo.hash}} <i class="el-icon-top-right el-icon--right"></i></el-link>
        </span>
      </el-row>
      <span slot="footer" class="dialog-footer">
        <el-button type="primary" @click="executedDialogVisible = false">{{$t('message.ok')}}</el-button>
      </span>
    </el-dialog>
  </div>
</template>

<script>
import { config, faucetContractConfig } from "../contracts-config";
import { TxState, ErrorType } from "../enums";
import Web3 from "web3";
// import HistoryTransactionPanel from "./HistoryTransactionPanel.vue";
import CurrentTransactionPanel from "./CurrentTransactionPanel.vue";
import InfoPanel from "./InfoPanel";
import { getScanUrl } from '../utils'

export default {
  components: {
    // CsvPanel,
    InfoPanel,
    // HistoryTransactionPanel,
    CurrentTransactionPanel
  },
  name: "FaucetPanel",
  data() {
    return {
      selectedToken: "",
      depositAmount: "",
      defaultDepositAmount: "10",

      contract: null,
      tokenBalance: null,

      faucetCfxBalance: null,
      faucetTokenBalance: null,
      faucetInterval: null,
      faucetAmount: null,

      isNativeToken: false,

      txState: TxState.NoTask,
      // transactionList: [],
      latestTransactionInfo: {
        hash: null,
        selectedToken: null,
        tokenAddress: null,
        networkVersion: null,
        confirmDate: null,
        from: null,
        isNativeToken: null,
        isClaim: null,
        amount: null
      },

      errors: {
        csvError: null,
        transactionError: null,
        balanceError: null
      },
      tagTheme: "dark",

      config: null,
      executedDialogVisible: false,
      // faucetContract: null,

      DEBUG: process.env.NODE_ENV !== "production"
    };
  },
  computed: {
    scanTransacationUrl() {
      if(!this.latestTransactionInfo) return ""
      return getScanUrl(this.latestTransactionInfo.hash, 'transaction', this.networkVersion)
    },
    account() {
      return this.$store.state.account;
    },
    conflux() {
      return this.$store.state.conflux;
    },
    confluxJS() {
      return this.$store.state.confluxJS;
    },
    sdk() {
      return this.$store.state.sdk;
    },
    cfxBalance() {
      return this.$store.state.cfxBalance;
    },
    networkVersion() {
      return this.conflux?.networkVersion;
    },
    queryingBalance() {
      if (this.isNativeToken) {
        return this.cfxBalance === null
          ? this.$t("message.warning.connectionWarning")
          : this.sdk.Drip(this.cfxBalance).toCFX();
      }

      if (!this.account) {
        return this.$t("message.warning.connectionWarning");
      }

      if (!this.selectedToken) {
        return this.$t("message.warning.tokenWarning");
      }

      // tokenBalance is updated using async function
      // check tokenBalance before presenting value
      return this.tokenBalance
        ? this.sdk.Drip(this.tokenBalance).toCFX()
        : this.$t("message.onRequest");
    },
    queryingFaucetBalance() {
      if (this.isNativeToken) {
        return this.faucetCfxBalance === null
          ? this.$t("message.onRequest")
          : this.sdk.Drip(this.faucetCfxBalance).toCFX();
      }

      if (!this.selectedToken) {
        return this.$t("message.warning.tokenWarning");
      }

      // tokenBalance is updated using async function
      // check tokenBalance before presenting value
      return this.faucetTokenBalance
        ? this.sdk.Drip(this.faucetTokenBalance).toCFX()
        : this.$t("message.onRequest");
    },
    stateType() {
      switch (this.txState) {
        case TxState.Error:
          return "danger";
        case TxState.Confirmed:
          return "success";
        case TxState.Executed:
        case TxState.Pending:
          return "warning";
        default:
          return "info";
      }
    },
    stateMessage() {
      switch (this.txState) {
        case TxState.Error:
          return TxState.Error + ":" + this.errors["transactionError"].message;
        case TxState.Executed:
          return (
            TxState.Executed +
            ", Not Confirmed yet. TransactionHash: " +
            this.latestTransactionInfo.hash
          );
        default:
          return this.txState;
      }
    },
    isFreeState() {
      return this.txState === TxState.Executed || TxState.isFree(this.txState);
    },

    hasTask() {
      return this.txState !== TxState.NoTask;
    },

    accountConnected() {
      return this.$store.state.account !== null;
    },
    options() {
      const tmp = [
        {
          label: "CFX",
          value: "CFX"
        }
      ];
      if (!config) {
        return tmp;
      }
      Object.keys(config).forEach(option => {
        tmp.push({
          value: option,
          label: config[option].label,
          // not strict equal
          disabled:
            this.$store.state.sdk?.address?.decodeCfxAddress(config[option].address)?.netId !=
            this.$store.state.conflux?.networkVersion
        });
      });
      // this.options = tmp;
      return tmp;
    },
    faucetContract() {
      if (!this.confluxJS || !this.sdk || !this.conflux) return null;
      if (parseInt(this.networkVersion) !== 1) return null;
      return this.confluxJS.Contract(faucetContractConfig[parseInt(this.networkVersion)]);
    },
    isDev() {
      return this.$store.state.isDev;
    },
    isButtonDisabled() {
      return !this.isFreeState || !Boolean(this.account) || !Boolean(this.selectedToken);
    }
  },
  watch: {
    // transactionList(newVal) {
    //   localStorage.faucetTransactionList = JSON.stringify(newVal);
    // },
    account(newVal) {
      if (newVal) {
        // 异步操作
        this.updateTokenBalance();
      } else {
        this.resetBalance();
      }
    },
    async faucetContract(newVal) {
      console.log(newVal)
      if (newVal) {
        this.faucetCfxBalance = (await this.confluxJS.getBalance(newVal.address)).toString();
        this.faucetAmount = this.sdk
          .Drip((await newVal.defaultAmount()).toString())
          .toCFX();
        this.faucetInterval = (await newVal.interval()).toString()
      }
    }
  },
  mounted() {
    // if (localStorage.faucetTransactionList) {
    //   this.transactionList = JSON.parse(localStorage.faucetTransactionList);
    // }

    // executed immediately after page is fully loaded
    this.$nextTick(function() {
      this.config = config;
      this.faucetContractConfig = faucetContractConfig[1];
      // this.faucetContract = window.confluxJS.Contract(faucetContractConfig[1]);
      this.web3 = new Web3();
    });
  },
  methods: {
    
    notifyTxState() {
      if (this.txState === TxState.Executed && this.latestTransactionInfo.isClaim) {
        this.executedDialogVisible = true;
      } else {
          this.$notify({
          title: this.txState,
          // message: this.stateM,
          type: this.stateType,
          offset: 60,
          duration: 6000
        });
      }
      
    },
    async authorize() {
      try {
        await this.$store.dispatch("authorize");
        await this.updateTokenBalance();
      } catch (e) {
        this.processError(e);
      }
    },
    showTxState() {
      this.$alert(this.stateMessage, this.$t('message.currentTransactionStatus'), {
        showClose: false,
        showCancelButton: false,
        showConfirmButton: false,
        closeOnClickModal: true,
        closeOnPressEscape: true,
        callBack: () => {}
      }).catch(() => {
        // 点击框外触发
        // do nothing
      });
    },
    async updateTokenBalance() {
      // console.log(this.account)
      try {
        if (!this.account || !this.contract) {
          return;
        }

        const tokenBalance = (await this.contract.balanceOf(this.account)).toString();
        this.tokenBalance = tokenBalance;
        console.log("Account tokenBalance: ");

        console.log(tokenBalance);
      } catch (e) {
        e._type = ErrorType.BalanceError;
        throw e;
      }
    },
    async updateFaucetCfxBalance() {
      this.faucetCfxBalance = (
        await this.confluxJS.getBalance(this.faucetContract.address)
      ).toString();
    },
    async updateFaucetTokenBalance() {
      try {
        if (!this.contract) {
          return;
        }

        const tokenBalance = (
          await this.contract.balanceOf(this.faucetContract.address)
        ).toString();
        this.faucetTokenBalance = tokenBalance;
        // console.log("Account tokenBalance: ");

        // console.log(tokenBalance);
      } catch (e) {
        e._type = ErrorType.BalanceError;
        throw e;
      }
    },
    async changeToken() {
      console.log("Selected token changed to %s", this.selectedToken);

      if (this.selectedToken === "CFX") {
        this.isNativeToken = true;
        this.contract = null;
        return;
      }
      this.isNativeToken = false;

      try {
        this.contract = this.confluxJS.Contract(this.config[this.selectedToken]);
        // use await to catch error
        await this.updateTokenBalance();
        await this.updateFaucetTokenBalance();
      } catch (e) {
        this.processError(e);
      }
    },
    fromCfxToDrip(cfx) {
      return this.sdk.Drip.fromCFX(cfx);
    },
    async claim() {
      this.resetLatestTransactionInfo();
      this.txState = TxState.NoTask;
      this.errors[ErrorType.TransactionError] = null;
      try {
        // 重新获取授权
        await this.authorize();

        let pendingTx;
        this.latestTransactionInfo.networkVersion = this.networkVersion;
        this.latestTransactionInfo.from = this.account;
        this.latestTransactionInfo.isNativeToken = this.isNativeToken;
        this.latestTransactionInfo.isClaim = true;
        this.latestTransactionInfo.amount = this.sdk
        
          .Drip((await this.faucetContract.defaultAmount()).toString())
          .toCFX();

        if (!this.isNativeToken) {
          const tx = this.faucetContract.claimToken(this.contract.address);

          const estimate = await tx.estimateGasAndCollateral({
            from: this.account
          });
          console.log(estimate);

          pendingTx = tx.sendTransaction({
            from: this.account,
            value: 0,
            gasPrice: 1,
            gas: estimate.gasLimit
          });

          this.latestTransactionInfo.selectedToken = this.selectedToken;
          this.latestTransactionInfo.tokenAddress = this.contract.address;
        } else {
          const tx = this.faucetContract.claimCfx();

          const estimate = await tx.estimateGasAndCollateral({
            from: this.account
          });
          console.log(estimate);

          pendingTx = tx.sendTransaction({
            from: this.account,
            value: 0,
            gasPrice: 1,
            gas: estimate.gasLimit
          });

          this.latestTransactionInfo.selectedToken = "CFX";
          this.latestTransactionInfo.tokenAddress = this.faucetContract.address;
        }

        // this step will ask user for authorization
        await pendingTx;
        this.txState = TxState.Pending;

        this.notifyTxState();
        let receipt = await pendingTx.executed();
        this.latestTransactionInfo.hash = receipt.transactionHash;
        this.txState = TxState.Executed;

        this.latestTransactionInfo.confirmDate = Date.now();
        // deep copy
        // 执行后立刻加入历史交易列表
        // this.transactionList.push(JSON.parse(JSON.stringify(this.latestTransactionInfo)));

        await this.$store.dispatch("updateCfxBalance");
        await this.updateTokenBalance();
        await this.updateFaucetCfxBalance();
        await this.updateFaucetTokenBalance();

        this.notifyTxState();
        receipt = await pendingTx.confirmed();

        // 用户在executed之后就可以操作了
        // 如果用户在未确认之前就已经进行了操作，那么当前交易的哈希就会与本次交易不一致，就不再进行状态变更与提示等操作
        // 否则仍然提示
        if (this.latestTransactionInfo.hash === receipt.transactionHash) {
          this.txState = TxState.Confirmed;
          this.notifyTxState();
        }
      } catch (err) {
        err._type = ErrorType.TransactionError;
        this.processError(err);
      }
    },
    async deposit() {
      this.resetLatestTransactionInfo();
      this.txState = TxState.NoTask;
      this.errors[ErrorType.TransactionError] = null;
      try {
        // 重新获取授权
        await this.authorize();

        const amount = this.depositAmount ? this.depositAmount : this.defaultDepositAmount;

        let pendingTx;
        this.latestTransactionInfo.networkVersion = this.networkVersion;
        this.latestTransactionInfo.from = this.account;
        this.latestTransactionInfo.isNativeToken = this.isNativeToken;
        this.latestTransactionInfo.amount = amount;
        this.latestTransactionInfo.isClaim = false;

        if (!this.isNativeToken) {
          const tx = this.contract.transfer(
            this.faucetContract.address,
            this.fromCfxToDrip(amount)
          );

          const estimate = await tx.estimateGasAndCollateral({
            from: this.account
          });
          console.log(estimate);

          pendingTx = tx.sendTransaction({
            from: this.account,
            value: 0,
            gasPrice: 1,
            gas: estimate.gasLimit
          });

          this.latestTransactionInfo.selectedToken = this.selectedToken;
          this.latestTransactionInfo.tokenAddress = this.contract.address;
        } else {
          pendingTx = this.confluxJS.sendTransaction({
            from: this.account,
            value: this.fromCfxToDrip(amount),
            to: this.faucetContract.address,
            gasPrice: 1,
            gas: 31000
          });

          this.latestTransactionInfo.selectedToken = "CFX";
          this.latestTransactionInfo.tokenAddress = this.faucetContract.address;
        }

        // this step will ask user for authorization
        await pendingTx;
        this.txState = TxState.Pending;

        this.notifyTxState();
        let receipt = await pendingTx.executed();
        this.latestTransactionInfo.hash = receipt.transactionHash;
        this.txState = TxState.Executed;

        this.latestTransactionInfo.confirmDate = Date.now();

        // deep copy
        // this.transactionList.push(JSON.parse(JSON.stringify(this.latestTransactionInfo)));

        await this.$store.dispatch("updateCfxBalance");
        await this.updateTokenBalance();
        await this.updateFaucetCfxBalance();
        await this.updateFaucetTokenBalance();

        this.notifyTxState();
        receipt = await pendingTx.confirmed();

        this.txState = TxState.Confirmed;
        this.notifyTxState();
      } catch (err) {
        err._type = ErrorType.TransactionError;
        this.processError(err);
      }
    },
    processError(err) {
      console.log(err);
      console.log(err._type);
      // balanceError csvError transactionError
      switch (err._type) {
        case ErrorType.BalanceError:
          this.tokenBalance = null;
          this.$store.commit("resetCfxBalance");
          this.errors[err._type] = err;
          this.$alert(err.message, this.$t("message.error.error"));
          break;
        // case ErrorType.CsvError:
        //   this.errors[err._type] = err;
        //   break;
        case ErrorType.TransactionError:
          this.errors[err._type] = err;
          this.txState = TxState.Error;
          this.$alert(err.message, this.$t("message.error.transactionError"));
          break;
        default:
      }
      // console.log(this.errors)
    },

    resetBalance() {
      // this.$store.commit("resetCfxBalance");
      this.tokenBalance = null;
    },
    // resetTransactionList() {
    //   this.transactionList = [];
    // },
    resetLatestTransactionInfo() {
      this.latestTransactionInfo = {
        hash: null,
        selectedToken: null,
        tokenAddress: null,
        networkVersion: null,
        confirmDate: null,
        from: null,
        isNativeToken: null,
        isClaim: null,
        amount: null
      };
    }
  }
};
</script>

<style scoped>
.full-height {
  height: 100%;
  /* align: middle; */
}

.full-width {
  width: 100%;
}

.right-align {
  text-align: right;
}

.center-align {
  text-align: center;
}

.bold-font {
  font-weight: bold;
}

.white-font {
  color: white;
}

.el-card {
  margin: 10px;
}

.success-message {
  font-size: 20px;
}
</style>
