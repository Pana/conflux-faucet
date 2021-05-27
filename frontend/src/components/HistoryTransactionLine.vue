<template>
  <el-collapse-item>
    <!-- <template slot="title"> -->
      <el-row type="flex" slot="title" class="full-width">
        <el-col :span="4">
          <div>代币: {{selectedToken}}</div>
        </el-col>
        <el-col :span="6">
          <div>操作类型: <span v-if="!isClaim">存入</span><span v-if="isClaim">领取</span></div>
        </el-col>
        <el-col :span="8">
          <div>代币数: {{ amount }}</div>
        </el-col>
        <el-col :span="12" style="text-align:right">
          <div >{{formattedDate}} </div>
        </el-col>
      </el-row>
    <el-row>
      <span>交易哈希：<el-link :href="scanTransacationUrl" type="primary" target="_blank">{{hash}} <i class="el-icon-top-right el-icon--right"></i></el-link></span>
    </el-row>
    <el-row>
      操作者:
      <el-link :href="scanFromUrl" type="primary" target="_blank">{{from}} <i class="el-icon-top-right el-icon--right"></i></el-link>
    </el-row>
    <el-row v-if="!isNativeToken">
      代币合约地址:
      <el-link :href="scanContractUrl" type="primary" target="_blank">{{tokenAddress}} <i class="el-icon-top-right el-icon--right"></i></el-link>
    </el-row>
  </el-collapse-item>
</template>
<script>
import { getScanUrl } from '../utils'

export default {
  name: "HistoryTransactionLine",
  props: ["transactionInfo"],
  data() {
    return {
    };
  },
  computed: {
    hash() {
      return this.transactionInfo.hash
    },
    confirmDate() {
      return this.transactionInfo.confirmDate
    },
    selectedToken() {
      return this.transactionInfo.selectedToken
    },
    tokenAddress() {
      return this.transactionInfo.tokenAddress
    },
    networkVersion() {
      return this.transactionInfo.networkVersion
    },
    from() {
      return this.transactionInfo.from
    },
    isNativeToken() {
      return this.transactionInfo.isNativeToken
    },
    isClaim() {
      return this.transactionInfo.isClaim
    },
    amount() {
      return this.transactionInfo.amount
    },
    formattedDate() {
      if (!this.confirmDate) return ""
      var date = new Date(this.confirmDate + 8 * 3600 * 1000); // 增加8小时
      return date.toJSON().substr(0, 19).replace('T', ' ');
    },
    scanTransacationUrl() {
      return getScanUrl(this.hash, 'transaction', this.networkVersion)
    },
    scanContractUrl() {
      return getScanUrl(this.tokenAddress, 'address', this.networkVersion)
    },
    scanFromUrl() {
      return getScanUrl(this.from, 'address', this.networkVersion)
    }
  },
};
</script>

<style scoped></style>
