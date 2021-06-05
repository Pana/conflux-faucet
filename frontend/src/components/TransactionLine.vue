<template>
  <el-collapse-item>
      <el-row type="flex" slot="title" class="full-width">
        <el-col :span="4">
          <div>{{$t('message.token')}}: {{selectedToken}}</div>
        </el-col>
        <el-col :span="6">
          <div>{{$t('message.operationType')}}: <span v-if="!isClaim">存入</span><span v-if="isClaim">{{$t('message.claim')}}</span></div>
        </el-col>
        <el-col :span="8">
          <div>{{$t('message.tokenAmount')}}: {{ amount }}</div>
        </el-col>
        <el-col :span="12" style="text-align:right">
          <div >{{formattedDate}} </div>
        </el-col>
      </el-row>
    <el-row>
      <span>{{$t('message.transactionHash')}}：<el-link :href="scanTransacationUrl" type="primary" target="_blank">{{hash}} <i class="el-icon-top-right el-icon--right"></i></el-link></span>
    </el-row>
    <el-row>
      {{$t('message.operator')}}:
      <el-link :href="scanFromUrl" type="primary" target="_blank">{{from}} <i class="el-icon-top-right el-icon--right"></i></el-link>
    </el-row>
    <el-row v-if="!isNativeToken">
      {{$t('message.tokenContractAddress')}}:
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
    timestamp() {
      return this.transactionInfo.timestamp
    },
    selectedToken() {
      return this.transactionInfo.selectedToken
    },
    tokenAddress() {
      return this.transactionInfo.tokenAddress
    },
    chainId() {
      return this.transactionInfo.chainId
    },
    from() {
      return this.transactionInfo.from
    },
    isNativeToken() {
      return this.transactionInfo.selectedToken === "CFX"
    },
    isClaim() {
      return this.transactionInfo.isClaim
    },
    amount() {
      return this.transactionInfo.amount
    },
    formattedDate() {
      // +UTC8 -480
      const tzOffset = new Date().getTimezoneOffset()

      if (!this.timestamp) return ""
      var date = new Date(this.timestamp - tzOffset * 60 * 1000); // 对应时区调整显示时间，但没有在其他时区进行过测试
      return date.toJSON().substr(0, 19).replace('T', ' ');
    },
    scanTransacationUrl() {
      return getScanUrl(this.hash, 'transaction', this.chainId)
    },
    scanContractUrl() {
      return getScanUrl(this.tokenAddress, 'address', this.chainId)
    },
    scanFromUrl() {
      return getScanUrl(this.from, 'address', this.chainId)
    }
  },
};
</script>

<style scoped></style>
