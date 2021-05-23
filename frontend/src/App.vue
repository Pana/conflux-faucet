<template>
  <div id="app">
    <el-container style="height: 100%">
      <el-header style="background: #409EFF">
        <el-row class="full-height" type="flex" align="middle" justify="left">
          <el-col :span="6">
            <label class="white-font bold-font">Conflux 测试网水龙头</label>
          </el-col>
          <el-col :offset="8" :span="2">
            <el-switch
              style="display: block"
              v-model="isDev"
              active-color="#13ce66"
              inactive-text="开发模式"
              @change="changeDev"
            >
            </el-switch>
          </el-col>
          <el-col :offset="1" :span="3">
            <el-tooltip effect="light" content="在 Conflux Portal 中切换网络">
              <el-tag>{{ networkText }}</el-tag>
            </el-tooltip>
          </el-col>

          <el-col :span="4" v-if="!accountConnected">
            <el-button class="full-width" round v-on:click="authorize">连接钱包</el-button>
          </el-col>
          <el-col :span="4" v-if="accountConnected">
            <el-button class="full-width" type="success" @click="showAccount">
              {{ simplifiedAccount }}<i class="el-icon-check el-icon--right"></i>
            </el-button>
          </el-col>
        </el-row>
      </el-header>

      <el-main class="main-background">
        <faucet-panel></faucet-panel>
      </el-main>
    </el-container>
  </div>
</template>

<script>
import FaucetPanel from "./components/FaucetPanel.vue";
import { getScanHtml } from "./utils";
// import BatchSender from './components/BatchSender.vue';

export default {
  components: {
    // BatchSender

    FaucetPanel
  },
  name: "App",
  data() {
    return {
      // DEBUG: process.env.NODE_ENV !== 'production'
      isDev: this.$store.state.isDev
    };
  },
  computed: {
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
    networkText() {
      switch (this.conflux?.networkVersion) {
        case "1029":
          return "Conflux Tethys";
        case "1":
          return "Conflux Testnet";
        case undefined:
          return "Portal Not Detected";
      }

      return "networkId: " + this.conflux?.networkVersion;
    },
    networkVersion() {
      return this.conflux?.networkVersion;
    },
    simplifiedAccount() {
      return this.$store.getters.simplifiedAccount;
    },
    accountConnected() {
      return this.$store.state.account !== null;
    },
    // isDev() {
    //   return this.$store.state.isDev;
    // }
  },
  mounted() {
    // executed immediately after page is fully loaded
    this.$nextTick(function() {
      if (typeof window.conflux !== "undefined") {
        this.$store.dispatch("init", {
          conflux: window.conflux,
          confluxJS: window.confluxJS,
          sdk: window.ConfluxJSSDK
        });
      }
    });
  },
  watch: {
    networkVersion(newVal) {
      if (newVal === undefined) {
        return;
      }
      if (parseInt(window.conflux.networkVersion) !== 1) {
        console.log(this.networkVersion);
        this.$alert("请在 Conflux Portal 中切换至测试网, 并手动刷新页面", "网络错误", {
          showClose: false,
          showCancelButton: false,
          showConfirmButton: false,
          // closeOnClickModal: true,
          // closeOnPressEscape: true,
          callBack: () => {}
        }).catch(() => {
          // 点击框外触发
          // do nothing
        });
      }
    }
  },
  methods: {
    async authorize() {
      try {
        await this.$store.dispatch("authorize");
      } catch (e) {
        this.processError(e);
      }
    },
    processError(err) {
      this.$alert(err.message, "错误");
    },
    changeDev() {
      // this.isDev ^= 1
      this.$store.commit("changeDev")
    },
    showAccount() {
      this.$alert(
        this.account +
          "<br>" +
          getScanHtml(this.account, "address", this.networkVersion, "在 ConfluxScan 上查看"),
        "当前账户地址",
        {
          showClose: false,
          showCancelButton: false,
          showConfirmButton: false,
          closeOnClickModal: true,
          closeOnPressEscape: true,
          dangerouslyUseHTMLString: true
          // callBack: ()=>{}
        }
      ).catch(() => {
        // 点击框外触发
        // do nothing
      });
    }
  }
};
</script>

<style>
html,
body,
#app {
  font-family: Avenir, Helvetica, Arial, sans-serif;
  -webkit-font-smoothing: antialiased;
  -moz-osx-font-smoothing: grayscale;
  /* text-align: center; */
  color: #2c3e50;
  /* margin-top: 60px; */
  padding: 0px;
  margin: 0px;
  height: 100%;
}

.main-background {
  /* background: #E4E7ED; */
  background: #ebeef5;
}

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
</style>
